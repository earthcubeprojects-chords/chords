#!/bin/bash

if [[ -v CERT_CREATE ]]
then
   nginx_conf_file="nginx_cert_create.conf"
   echo "nginx will be configured for certificate creation mode."
elif [[ $SSL_ENABLED = "true" ]]
then
   nginx_conf_file="nginx_ssl_on.conf"
   echo "nginx will be configured with SSL enabled."
else
   nginx_conf_file="nginx_ssl_off.conf"
   echo "nginx will be configured with SSL disabled."
fi

echo "nginx configuration: $nginx_conf_file"
envsubst '$SSL_HOST:$SSL_CHORDS_DIR:$SSL_EMAIL'  < /tmp/$nginx_conf_file > /etc/nginx/conf.d/$nginx_conf_file
cat /etc/nginx/conf.d/$nginx_conf_file

# start Nginx in foreground so Docker container doesn't exit
nginx -g "daemon off;"