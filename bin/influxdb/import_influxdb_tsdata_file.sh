#!/bin/sh

influx -username $INFLUXDB_USERNAME -password $INFLUXDB_PASSWORD -database chords_ts_production -import -compressed -precision=ns -path=/tmp/chords-influxdb-dump.gz
