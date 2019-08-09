#!/usr/bin/env bash
 

# substitute variable references in the Nginx config template for real values from the environment

if [[ $SSL_ENABLED = "true" ]]
then
  envsubst '$SSL_HOST:$SSL_CHORDS_DIR:$SSL_CERT_EMAIL'  < /tmp/ssl.nginx > /etc/nginx/conf.d/default.conf
else
  envsubst '$SSL_HOST:$SSL_CHORDS_DIR:$SSL_CERT_EMAIL'  < /tmp/default.nginx > /etc/nginx/conf.d/default.conf
fi

# start Nginx in foreground so Docker container doesn't exit
nginx -g "daemon off;"