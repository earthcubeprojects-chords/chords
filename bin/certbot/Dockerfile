FROM certbot/certbot 

# Install Docker on the container itself, so that this 
# container can can ask docker to restart nginx after cert renewal.
RUN apk add --no-cache bash docker

WORKDIR /

# Add our management scripts.
COPY bin/certbot/*.sh ./

# Start certbot
ENTRYPOINT ["/bin/sh", "-f", "certbot_start.sh"]
