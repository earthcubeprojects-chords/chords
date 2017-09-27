#!/bin/sh

influx_inspect export -compress -database chords_ts_production -datadir /var/lib/influxdb/data -waldir /var/lib/influxdb/wal -out /tmp/chords-influxdb-dump.gz
