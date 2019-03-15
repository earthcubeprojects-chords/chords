"""
Backup CHORDS databases.
"""
import datetime
import getpass
import platform
import sh

from docker_util import docker_bash, docker_cp

class ChordsBackupError(Exception):
    """ Raise ChordsBackupError("error msg"). """
    pass


def id_check():
    """ Verify that the user is running with the correct permissions. """

    if platform.system() == "Linux":
        if getpass.getuser() != 'root':
            raise ChordsBackupError("CHORDS load must be run as root user on Linux systems.")

def manifest(time_stamp, influx_file, mysql_file):
    """
    Create a manifest file.
    """

    file_name = "manifest-" + time_stamp + ".txt"
    manifest_file = open(file_name, "w")

    manifest_file.write("# CHORDS backup\n")
    manifest_file.write("# Project: " + mysql_value(table="profiles", column="project") + "\n")
    manifest_file.write("# Affiliation: " + mysql_value(table="profiles", column="affiliation") + "\n")
    manifest_file.write("# Domain name: " + mysql_value(table="profiles", column="domain_name") + "\n")
    manifest_file.write(
        "# MYQSL database dump file: %s\n" % (mysql_file)
    )
    manifest_file.write(
        "# InfluxDB database dump file: %s\n" % (influx_file)
    )
    manifest_file.write("# Environment:\n")
    env_vars = docker_bash("chords_app", "grep export chords_env.sh | sed -e 's/export //'")
    manifest_file.write(env_vars)
    docker_tag = "DOCKER_TAG=" + docker_bash("chords_app", "printenv DOCKER_TAG")
    manifest_file.write(docker_tag)
    manifest_file.close()
    return file_name

def mysql_value(table, column):
    """ Fetch a mysql field. """
    value = docker_bash(
        "chords_mysql",
        '/usr/bin/mysql -s -N -e "use chords_demo_production; select %s from %s;"' % (column, table))
    value = value.strip()
    return value

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
    print(docker_bash(
        "chords_influxdb", "cd /tmp && influxd backup -portable %s" % (influx_dump_dir)))
    print(docker_bash(
        "chords_influxdb", "cd /tmp && tar -cvf %s %s" % (influx_tar_file, influx_dump_dir)))
    docker_cp('chords_influxdb:%s' % ("/tmp/"+influx_tar_file), '.')
    print(docker_bash(
        "chords_influxdb", "cd /tmp && rm -rf %s %s" % (influx_tar_file, influx_dump_dir)))

    print("*** Manifest ***:")
    manifest_file = manifest(
        time_stamp=time_stamp, influx_file=influx_tar_file, mysql_file=mysql_dump_file)
    print("%s has been created." % (manifest_file))
    print("")

    print("*** Packaging files ***")
    tar_params = ['-cvf', chords_tar_file, manifest_file, mysql_dump_file, influx_tar_file]
    print(sh.tar(tar_params, _err_to_out=True).stdout)
    print(sh.rm(manifest_file, mysql_dump_file, influx_tar_file))

    print("*** Success ***")
    print("%s has ben created." % (chords_tar_file))

if __name__ == '__main__':
    try:
        main()
    except ChordsBackupError as error:
        print(error)
        exit(1)

    exit(0)
