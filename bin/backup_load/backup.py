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
    influx_dump_dir = 'influxdb-'+time_stamp
    influx_tar_file = 'influxdb-'+time_stamp+'.tar'
    chords_tar_file = 'chords-'+time_stamp+'.tar.gz'

    print("*** Saving mysql ***")
    mysql_file = open(mysql_dump_file, 'w')
    print(sh.docker('exec -t chords_mysql /usr/bin/mysqldump chords_demo_production'.split(),
                    _out=mysql_file).stdout)
    print("")

    print("*** Saving influxdb ***")
    print(sh.docker('exec', '-t', 'chords_influxdb',
                    'ls', '-l', '/tmp',
                    _err_to_out=True).stdout)
    print(sh.docker('exec', '-t', 'chords_influxdb',
                    '/bin/bash', '-c', "cd /tmp && influxd backup -portable %s" % (influx_dump_dir),
                    _err_to_out=True).stdout)
    print(sh.docker('exec', '-t', 'chords_influxdb',
                    '/bin/bash', '-c', "cd /tmp && tar -cvf %s %s" % (influx_tar_file, influx_dump_dir),
                    _err_to_out=True).stdout)
    print(sh.docker('cp',
                    'chords_influxdb:%s' % ("/tmp/"+influx_tar_file), '.',
                    _err_to_out=True).stdout)
    print(sh.docker('exec', '-t', 'chords_influxdb',
                    '/bin/bash', '-c', "cd /tmp && rm -rf %s %s" % (influx_tar_file, influx_dump_dir),
                    _err_to_out=True).stdout)

    print("*** Packaging files ***")
    tar_params = ['-cvf', chords_tar_file, mysql_dump_file, influx_tar_file]
    print(sh.tar(tar_params, _err_to_out=True).stdout)
    print(sh.rm(mysql_dump_file, influx_tar_file))
    print("%s has ben created." % (chords_tar_file))
