import os
import sh
import datetime

#####################################################################
#####################################################################

if __name__ == '__main__':
    
    time_stamp = datetime.datetime.now().replace(microsecond=0).isoformat()
    influx_dump_dir = '/tmp/influxdb-'+time_stamp
    tarfile = influx_dump_dir+'.tgz'
    docker_cmds = [
        'ps -a',
        'exec -t chords_influxdb sh -c ls -l /tmp',
        'exec -t chords_influxdb influxd backup -database chords_ts_production %s' %(influx_dump_dir),
        'exec -t chords_influxdb tar -cvzf %s %s' % (tarfile, influx_dump_dir),
        'cp chords_influxdb:%s .' % (tarfile),
        'exec -t chords_influxdb rm %s' % (tarfile),
        'exec -t chords_influxdb rm -rf %s' % (influx_dump_dir)
    ]

    for cmd in docker_cmds:
        print(sh.docker(cmd.split()).stdout)