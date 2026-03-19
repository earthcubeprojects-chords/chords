#!/bin/bash

if [[ $SSL_ENABLED == "true" || $SSL_ENABLED == "TRUE" ]]; then
    caddy_conf_file="Caddyfile.ssl_on"
    echo "Caddy configured with SSL enabled (automatic HTTPS via Let's Encrypt)."
else
    caddy_conf_file="Caddyfile.ssl_off"
    echo "Caddy configured with SSL disabled (HTTP only)."
fi

echo "Caddy configuration: $caddy_conf_file"
cp /tmp/$caddy_conf_file /etc/caddy/Caddyfile
exec caddy run --config /etc/caddy/Caddyfile
