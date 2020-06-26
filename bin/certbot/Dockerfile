FROM certbot/certbot 

# Install Docker on the container itself, so that this 
# container can can ask docker to restart nginx after cert renewal.
RUN apk add --no-cache bash docker

WORKDIR /

# create the directory for certbot validation
RUN mkdir acme-challenge

# Add our management scripts.
COPY *.sh ./

# Start certbot
ENTRYPOINT ["/bin/sh", "-f", "certbot_start.sh"]
