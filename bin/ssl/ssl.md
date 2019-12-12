# SSL Integration
Factors involved with SSL integration in CHORDS:

* CHORDS may be run in either a non-SSL mode or an SSL mode.
* SSL certificates are created by using nginx and certbot in a standalone mode.
  The ``--no-deps`` switch applied to ``docker-compose run``
  and ``docker-compose up`` can be used to run nginx or certbot
  without starting other dependencies, ie. mysql, influxdb, etc.
* Nginx will use different configuration files, depending upon
  which mode is in play. Nginx configuration files for all
  modes are built into the nginx container, with some symbols
  designating configurable information.
* The nginx container contains a startup script which will choose which
  nginx configuration to use. It will make the variable substitutions
  prior to starting nginx.
* With CHORDS in SSL mode, certbot will be running in a certificate
  maintenance mode, attempting the renewal every 6 hours.
* In non-SSL mode, certbot will exit
* The certbot image is use for housekeeping activities,
  such as removing certificates, and generating dummy certificates.

## Configuration values

Related docker-compose environment (.env) variables:
  - SSL_ENABLED: "true" / "false".
  - SSL_HOST: The FQDN that accesses this portal. It must be
    operational prior to certificate generation. Can be blank if
    SSL_ENABLED == false.
  - SSL_EMAIL: The email to be associated with the cert. Can be blank
    if SSL_ENABLED == false.
  - CERT_CREATE: if present, nginx knows that it is being used
    only for certificate creation (define via command line
    arguement to ``docker-compose``)

## Docker volumes

| Directory        | Function          | Visibility | Comments |
|------------------|-------------------|------------|----------|
| /etc/letsencrypt | Certificates      |certbot, nginx| |
| /var/www/certbot | ACME challenge    |certbot, nginx| |

## Certificates

When certificates are to be generated, or replaced:

1.	Run oppenssl to create dummy certificates. Use certbot container for this.

        docker-compose run --no-deps --entrypoint " \
        mkdir -p /etc/letsencrypt/live/$SSL_HOST" certbot

        docker-compose run --no-deps --entrypoint " \
        openssl req -x509 -nodes -newkey rsa:1024 -days 1 \
          -keyout '/etc/letsencrypt/live/$SSL_HOST/privkey.pem' \
          -out '/etc/letsencrypt/live/$SSL_HOST/fullchain.pem' \
          -subj '/CN=localhost'" certbot

1. Run nginx (as a daemon), in certificate creation mode. 
   nginx, which will be configured for SSL, can start because the 
   dummy certs are present.

        docker-compose run -e CERT_CREATE=1 -e SSL_HOST=$SSL_HOST -e SSL_EMAIL=$SSL_EMAIL -p 80:80 -p 443:443 --no-deps -d nginx

1. Run certbot with an ``rm`` entrypoint to erase dummy certificates:

        docker-compose run --no-deps --entrypoint " \
          rm -Rf /etc/letsencrypt/live/$SSL_HOST && \
          rm -Rf /etc/letsencrypt/archive/$SSL_HOST && \
          rm -Rf /etc/letsencrypt/renewal/$SSL_HOST.conf " \
          certbot

1.	Run certbot to request a certificate (“certonly” command) . This causes the following to happen:
- certbot requests a token from letsencrypt, which it places in the nginx accessible filesystem.
- letsencrypt retrieves the token via nginx.
- certbot is delivered the certificate, which it places it in the nginx SSL certificate directory.

        docker-compose run --nodeps --entrypoint "\
          certbot certonly \
           --webroot -w=/chords/public/certbot --email $SSL_EMAIL \
           --agree-tos --no-eff-email --staging -d $SSL_HOST" \
           certbot

1.	Shutdown nginx. 
