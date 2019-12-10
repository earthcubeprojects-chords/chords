FROM certbot/certbot 

WORKDIR /

COPY bin/certbot/certbot_start.sh certbot_start.sh

# Start certbot
ENTRYPOINT ["/bin/sh", "-f", "certbot_start.sh"]
