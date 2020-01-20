# Must be built from the top-level CHORDS directory.

# Base image:
FROM nginx

# Install dependencies
RUN apt-get update -qq && apt-get -y \
  install \
  apache2-utils \
  curl\
  nano 

# Set our working directory inside the image
WORKDIR /chords

# create log directory
RUN mkdir log

# Copy Nginx configuration
COPY bin/nginx/*.conf /tmp/

# EXPOSE http and https ports 
EXPOSE 80
EXPOSE 443

 # copy over the script that is run by the container
COPY bin/nginx/nginx_start.sh /tmp/

RUN chmod -R 777 /tmp/nginx_start.sh

# Use the "exec" form of CMD so Nginx shuts down gracefully on SIGTERM (i.e. `docker stop`)
# CMD [ "nginx", "-g", "daemon off;" ]
CMD [ "/tmp/nginx_start.sh" ]
