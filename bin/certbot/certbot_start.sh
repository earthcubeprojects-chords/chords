#!/bin/bash

# Certbot conditional startup
#
# Set SSL_ENABLED to true or TRUE to neable startup of certbot.
# Certbot will be started in a repeating certificate renewal mode.
#

if [ -z "$SSL_ENABLED" ]; then
  export SSL_ENABLED="false"
fi

if [ $SSL_ENABLED == "TRUE" ]; then
  export SSL_ENABLED="true"
fi

# If SSL is enabled, start certbot renewal attempts.
if [ $SSL_ENABLED == "true" ]; then
  echo "*** SSL is enabled; starting certbot in certificate renewal mode"
  /bin/sh -c 'trap exit TERM; while :; do date; certbot renew; sleep 6h & wait ${!}; done;'
else
  echo "SSL was not enabled (via SSL_ENABLED); certbot is not starting"
fi
