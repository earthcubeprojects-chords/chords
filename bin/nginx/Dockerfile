# Must be built from the top-level CHORDS directory.
FROM nginx

# Install dependencies
RUN apt-get update -qq && apt-get -y \
  install \
  apache2-utils \
  curl\
  nano \
  logrotate \
  cron \
  procps

WORKDIR /

# create the directory for certbot validation
RUN mkdir acme-challenge

# EXPOSE http and https ports 
EXPOSE 80
EXPOSE 443

# Install the nginx start script
COPY bin/nginx/nginx_start.sh /tmp/
RUN chmod -R 777 /tmp/nginx_start.sh

# Install logrotate configuration
COPY bin/nginx/logrotate_nginx /etc/logrotate.d/nginx

# Install Nginx configurations. They will be referenced
# in nginx_start.sh
COPY bin/nginx/*.conf /tmp/

# Remove console links for log files so that logs go to the file system.
RUN rm -f /var/log/nginx/access.log /var/log/nginx/error.log

# Run nginx
CMD [ "/tmp/nginx_start.sh" ]
