"""
Backup CHORDS databases.
"""
import sys
import datetime
import sh

#####################################################################

if __name__ == '__main__':

    time_stamp = datetime.datetime.now().replace(microsecond=0).isoformat()
    time_stamp = time_stamp.replace(":","-")
    mysql_dump_file = 'mysql-'+time_stamp+'.sql'
    influx_dump_file = 'influxdb-'+time_stamp+'.tar'
    chords_dump_file = 'chords-'+time_stamp+'.tar.gz'

    print("*** Saving mysql ***")
    mysql_file = open(mysql_dump_file, 'w')
    print(sh.docker('exec -t chords_mysql /usr/bin/mysqldump chords_demo_production'.split(),
                    _out=mysql_file).stdout)
    print("")

    print("*** Saving influxdb ***")
    influx_dump_dir = '/tmp/influxdb-'+time_stamp
    docker_cmds = [
        'exec -t chords_influxdb ls -l /tmp',
        'exec -t chords_influxdb influxd backup -database chords_ts_production %s' % \
            (influx_dump_dir),
        'exec -t chords_influxdb tar --force-local -cvf %s %s' % \
            (influx_dump_file, influx_dump_dir),
        'cp chords_influxdb:%s .' % (influx_dump_file),
        'exec -t chords_influxdb rm %s' % (influx_dump_file),
        'exec -t chords_influxdb rm -rf %s' % (influx_dump_dir)
    ]
    for cmd in docker_cmds:
        print(sh.docker(cmd.split(), _err_to_out=True).stdout)
    print("")

    print("*** Packaging files ***")
    tar_params = ['-cvf', chords_dump_file, mysql_dump_file, influx_dump_file]
    print(sh.tar(tar_params, _err_to_out=True).stdout)
    print(sh.rm(mysql_dump_file, influx_dump_file))
    print("%s has ben created." % (chords_dump_file))
