#!/bin/sh

influx -username admin -password chords_ec_demo -database chords_ts_development  -import -compressed -precision=ns -path=/tmp/chords-influxdb-backup
