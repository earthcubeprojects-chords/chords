"""
Backup CHORDS databases.
"""
import datetime
import os
import getpass
import sh

class ChordsBackupError(Exception):
    """ Raise ChordsBackupError("error msg"). """
    pass


def id_check():
    """ Verify that the user is running with the correct permissions. """

    if os.name == "posix":
        if getpass.getuser() != 'root':
            raise ChordsBackupError("CHORDS load must be run as root user on posix systems.")

def docker_bash(container, script):
    """
    Run shell comands in bash. This allows multiple
    commands to be &&'ed together
    """
    print(sh.docker('exec', '-t', container, '/bin/bash', '-c', script, _err_to_out=True).stdout)

def docker_cp(src, dest):
    """
    Copy file to/from container.
    """
    print(sh.docker('cp', src, dest, _err_to_out=True).stdout)

#####################################################################
def main():
    """
    Main.
    """
    id_check()

    time_stamp = datetime.datetime.now().replace(microsecond=0).isoformat()
    time_stamp = time_stamp.replace(":", "-")
    mysql_dump_file = 'mysql-'+time_stamp+'.sql'
    influx_dump_dir = 'influxdb-'+time_stamp
    influx_tar_file = 'influxdb-'+time_stamp+'.tar'
    chords_tar_file = 'chords-'+time_stamp+'.tar.gz'

    print("*** Saving mysql ***")
    mysql_file = open(mysql_dump_file, 'w')
    print(sh.docker('exec -t chords_mysql /usr/bin/mysqldump chords_demo_production'.split(),
                    _out=mysql_file).stdout)

    print("*** Saving influxdb ***")
    docker_bash("chords_influxdb", "cd /tmp && influxd backup -portable %s" % (influx_dump_dir))
    docker_bash("chords_influxdb", "cd /tmp && tar -cvf %s %s" % (influx_tar_file, influx_dump_dir))
    docker_cp('chords_influxdb:%s' % ("/tmp/"+influx_tar_file), '.')
    docker_bash("chords_influxdb", "cd /tmp && rm -rf %s %s" % (influx_tar_file, influx_dump_dir))

    print("*** Packaging files ***")
    tar_params = ['-cvf', chords_tar_file, mysql_dump_file, influx_tar_file]
    print(sh.tar(tar_params, _err_to_out=True).stdout)
    print(sh.rm(mysql_dump_file, influx_tar_file))
    print("%s has ben created." % (chords_tar_file))

if __name__ == '__main__':
    try:
        main()
    except ChordsBackupError as error:
        print(error)
        exit(1)

    exit(0)
