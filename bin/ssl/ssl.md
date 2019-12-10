# SSL Integration
Factors involved with SSL integration in CHORDS:

* CHORDS may be run in either a non-SSL mode or an SSL mode.
* SSL certificates are created by using nginx and certbot in a standalone mode.
* nginx will use different configuration files, depending upon which mode is
  in play. Nginx configuration files for all modes are built into the nginx
  container, with some symbols designating configurable information.
* The nginx container contains a startup script which will choose which
  nginx configuration to use. It will make the variable substitutions
  prior to starting nginx.
* With CHORDS in SSL mode, certbot will be running in a certificate
  renewal mode, attempting the renewal every 6 hours.
* In non-SSL mode, certbot will exit
* The certbot image is use for housekeeping activities,
  such as removing certificates, and generating dummy certificates. 

## Configuration values

Related docker-compose environment (.env) variables:
  - SSL_ENABLED: true or false
  - SSL_HOST: The FQDN that accesses this portal. It must be
    operational prior to certificate generation. Can be blank if
    SSL_ENABLED==false.
  - SSL_EMAIL: The email to be associated with the cert. Can be blank if
    SSL_ENABLED==false.
  - NGINX_CERT_CREATE: if present, nginx knows that it is being used only
    to create certificates.

## Docker volumes

| Directory        | Function          | Visibility | Comments |
|------------------|-------------------|------------|----------|
| /etc/letsencrypt | Certificates      |certbot, nginx| |
| /var/www/certbot | ACME challenge    |certbot, nginx| |

## Certificates

When certificates are to be generated, or replaced:

1.	Run oppenssl to create dummy certificates. Use certbot container for this.

        path="/etc/letsencrypt/live/$SSL_HOST"
        mkdir -p "$data_path/conf/live/$SSL_HOST"
        docker-compose run --rm --entrypoint " \
        openssl req -x509 -nodes -newkey rsa:1024 -days 1 \
          -keyout '$path/privkey.pem' \
          -out '$path/fullchain.pem' \
          -subj '/CN=localhost'" certbot

1. Run nginx (as a daemon), in certificate creation mode. 
   nginx, which will be configured for SSL, can start because the 
   dummy certs are present.

        NGINX_CERT_CREATE=1 docker-compose up --force-recreate -d nginx

1. Run certbot with an ``rm`` entrypoint to erase dummy certificates:

        rm -Rf /etc/letsencrypt/live/$SSL_HOST && \
        rm -Rf /etc/letsencrypt/archive/$SSL_HOST && \
        rm -Rf /etc/letsencrypt/renewal/$SSL_HOST.conf

1.	Run certbot to delete the dummy certs (as above).
1.	Run certbot to request a certificate (“certonly” command) . This causes the following to happen:
    - certbot requests a token from letsencrypt, which it places in the nginx accessible filesystem.
    - letsencrypt retrieves the token via nginx.
    - certbot is delivered the certificate, which it places it in the nginx SSL certificate directory.
1.	Shutdown nginx. 
