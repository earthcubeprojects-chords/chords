#!/bin/bash

# update the ip address for the network and restart postfix
docker exec chords_mta sed -in 's/\.17\./\.18\./g' /etc/postfix/main.cf
docker exec chords_mta service postfix stop
docker exec chords_mta rm /var/spool/postfix/pid/master.pid
docker exec chords_mta service postfix start
