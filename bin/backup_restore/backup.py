import os
import sh
import datetime

#####################################################################
#####################################################################

if __name__ == '__main__':
    
    time_stamp = datetime.datetime.now().replace(microsecond=0).isoformat()
    
    mysql_backp_file = 'mysql-'+time_stamp

    influx_dump_dir = '/tmp/influxdb-'+time_stamp
    influx_tarfile = influx_dump_dir+'.tgz'

    print("*** Dump mysql ***")
    docker_cmds = [
        'exec -t chords_mysql /usr/bin/mysqldump chords_demo_production'
    ]
    mysql_file = open(mysql_backp_file, 'w')
    print(sh.docker(docker_cmds[0].split(), _out=mysql_file).stdout)
    print(sh.gzip(mysql_backp_file).stdout)
    print("*********************")
    print("")

    print("***Dump influxdb ***")
    docker_cmds = [
        'ps -a',
        'exec -t chords_influxdb sh -c ls -l /tmp',
        'exec -t chords_influxdb influxd backup -database chords_ts_production %s' %(influx_dump_dir),
        'exec -t chords_influxdb tar -cvzf %s %s' % (influx_tarfile, influx_dump_dir),
        'cp chords_influxdb:%s .' % (influx_tarfile),
        'exec -t chords_influxdb rm %s' % (influx_tarfile),
        'exec -t chords_influxdb rm -rf %s' % (influx_dump_dir)
    ]

    for cmd in docker_cmds:
        print(sh.docker(cmd.split()).stdout)