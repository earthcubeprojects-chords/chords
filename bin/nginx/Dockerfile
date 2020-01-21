# Must be built from the top-level CHORDS directory.

# Base image:
FROM nginx

# Install dependencies
RUN apt-get update -qq && apt-get -y \
  install \
  apache2-utils \
  curl\
  nano 

WORKDIR /

# create the directory for certbot validation
RUN mkdir acme-challenge

# EXPOSE http and https ports 
EXPOSE 80
EXPOSE 443

 # Install the nginx start script
COPY bin/nginx/nginx_start.sh /tmp/
RUN chmod -R 777 /tmp/nginx_start.sh

# Install Nginx configurations. They will be referrenced
# in nginx_start.sh
COPY bin/nginx/*.conf /tmp/

# Run nginx
CMD [ "/tmp/nginx_start.sh" ]
