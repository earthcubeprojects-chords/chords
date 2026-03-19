# Must be built from the top-level CHORDS directory.
FROM caddy:2-alpine

RUN apk add --no-cache bash && mkdir -p /var/log/caddy

COPY bin/caddy/caddy_start.sh /tmp/
RUN chmod 755 /tmp/caddy_start.sh

COPY bin/caddy/Caddyfile.ssl_off /tmp/
COPY bin/caddy/Caddyfile.ssl_on /tmp/

EXPOSE 80
EXPOSE 443

CMD ["/tmp/caddy_start.sh"]
