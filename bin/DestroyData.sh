#!/bin/bash
docker-compose -p chords down
docker volume rm chords_influxdb-data
docker-compose -p chords up -d
sleep 5
