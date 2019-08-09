#!/bin/bash

/usr/local/bin/docker-compose -f /home/ec2-user/chords/docker-compose.yml run certbot renew --dry-run \
&& /usr/local/bin/docker-compose -f /home/ec2-user/chords/docker-compose.yml kill -s SIGHUP web