"""
Backup CHORDS databases.
"""
import sys
import datetime
import sh

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

if __name__ == '__main__':

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
