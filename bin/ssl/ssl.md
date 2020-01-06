# SSL Integration
Factors involved with SSL integration in CHORDS:

* CHORDS may be run in either a non-SSL mode or an SSL mode.
* SSL certificates are created by using nginx and certbot in a standalone mode.
  The ``--no-deps`` switch applied to ``docker-compose run``
  and ``docker-compose up`` can be used to run nginx or certbot
  without starting other dependencies, ie. mysql, influxdb, etc.,
  but still attachingthe volumes.
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

| Volume            | Directory            | Function          | Used By                 | Comments |
|-------------------|----------------------|-------------------|-------------------------|----------|
|letsencrypt-etc    | /etc/letsencrypt     | Certificates      |certbot, nginx           | letsencrypt configuration, certificates and renewal details are stored here.|
|letsencrypt-var-log| /var/lib/letsencrypt | Letsencrypt work directory | certbot, nginx | Not sure why this directory needs permanance. |
|letsencrypt-var-log| /var/log/letsencrypt | Letsencrypt logs | certbot |  |
|web-root           | /chords/public       | index.html, error.html, ACME challenge |certbot, nginx| Intially populated by nginx container, it contains a few error htmls, and is used for the ACME challenge.|

## Certificates

_The following script commands assume that SSL_HOST and SSL_EMAIL are set in the environment.
Make sure that they are defined._

When certificates are to be generated, or replaced:

1. Run oppenssl to create dummy certificates. Use certbot container for this.
```sh
  docker-compose run --no-deps --entrypoint " \
  mkdir -p /etc/letsencrypt/live/$SSL_HOST" certbot

  docker-compose run --no-deps --entrypoint " \
  openssl req -x509 -nodes -newkey rsa:1024 -days 1 \
    -keyout '/etc/letsencrypt/live/$SSL_HOST/privkey.pem' \
    -out '/etc/letsencrypt/live/$SSL_HOST/fullchain.pem' \
    -subj '/CN=localhost'" certbot
```
2. Run nginx (as a daemon), in certificate creation mode. 
   nginx, which will be configured for SSL, can start because the 
   dummy certs are present.
```sh
  docker-compose run -e CERT_CREATE=1 -e SSL_HOST=$SSL_HOST -e SSL_EMAIL=$SSL_EMAIL -p 80:80 -p 443:443 --no-deps -d nginx
```
3. Run certbot with an ``rm`` commands to erase dummy certificates:
```sh
  docker-compose run --no-deps --entrypoint " \
    rm -Rf /etc/letsencrypt/live/$SSL_HOST && \
    rm -Rf /etc/letsencrypt/archive/$SSL_HOST && \
    rm -Rf /etc/letsencrypt/renewal/$SSL_HOST.conf " \
    certbot
```
4. Run certbot to request a certificate (“certonly” command) . This causes the following
   to happen:
    1. certbot requests a token from letsencrypt, which it places in the nginx accessible filesystem.
    1. letsencrypt retrieves the token via nginx.
    1. certbot is delivered the certificate, which it places it in the nginx SSL certificate directory.

**Add ``--staging`` for initial testing, and make sure that succeeds, before getting a real certificate.** Remove it once everything passes. This is to avoid hitting the letsencrypt
rate limit.

```sh
  docker-compose run --no-deps --entrypoint "certbot certonly \
  --webroot -w=/chords/public --email $SSL_EMAIL --agree-tos \
  --no-eff-email --staging -d $SSL_HOST" certbot
```
5. Shutdown nginx (and other containers):

```sh
  docker-compose down
```
## Debugging
- See these [debugging tools](https://certbot.eff.org/faq#what-tools-can-i-use-for-debugging-my-site-s-https-configuration) when you are having problems.

- It is very useful to run a shell in an image, with the volumes mounted,
  but not starting dependent services. This allows you to see exactly what
  the container is mounting. Use the ``--no-deps`` flag:

```sh
docker-compose run --no-deps --entrypoint /bin/bash certbot
```

## Saving the Certificates (and Other Letsencrypt Artifacts)

The _letsencrypt_ environment, including the certificates will need to be saved/restored during
a CHORDS backup/restore operation:
```sh
docker-compose run --no-deps --rm --entrypoint "/bin/bash -c 'cd /etc/letsencrypt; tar --exclude etc-letsencrypt.tar -cvf etc-letsencrypt.tar .'" nginx

docker cp $(docker-compose ps -q nginx):/etc/letsencrypt/etc-letsencrypt.tar .
```
