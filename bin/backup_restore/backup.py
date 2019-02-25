import os
import sh
import datetime

#####################################################################
#####################################################################

if __name__ == '__main__':
    
    time_stamp = datetime.datetime.now().replace(microsecond=0).isoformat()
    
    mysql_dump_file = 'mysql-'+time_stamp+'.sql'
    influx_dump_file = 'influxdb-'+time_stamp+'.tar'
    chords_dump_file = 'chords-'+time_stamp+'.tgz'

    print("*** Dump mysql ***")
    docker_cmds = [
        'exec -t chords_mysql /usr/bin/mysqldump chords_demo_production'
    ]
    mysql_file = open(mysql_dump_file, 'w')
    print(sh.docker(docker_cmds[0].split(), _out=mysql_file).stdout)
    print("*********************")
    print("")

    print("***Dump influxdb ***")
    influx_dump_dir = '/tmp/influxdb-'+time_stamp
    docker_cmds = [
        'exec -t chords_influxdb ls -l /tmp',
        'exec -t chords_influxdb influxd backup -database chords_ts_production %s' %(influx_dump_dir),
        'exec -t chords_influxdb tar --force-local -cvf %s %s' % (influx_dump_file, influx_dump_dir),
        'cp chords_influxdb:%s .' % (influx_dump_file),
        'exec -t chords_influxdb rm %s' % (influx_dump_file),
        'exec -t chords_influxdb rm -rf %s' % (influx_dump_dir)
    ]
    for cmd in docker_cmds:
        print(sh.docker(cmd.split()).stdout)
    print("*********************")
    print("")

    print(sh.tar('-cvf', chords_dump_file, mysql_dump_file, influx_dump_file))
    print(sh.rm(mysql_dump_file, influx_dump_file))

