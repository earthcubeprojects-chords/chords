#!/bin/sh

influx_inspect export -database chords_ts_development -datadir /var/lib/influxdb/data -waldir /var/lib/influxdb/wal -out /tmp/chords-influxdb-backup -compress