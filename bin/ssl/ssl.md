# SSL Integration
Notes about the SSL integration in CHORDS:

* CHORDS may be run in either a non-SSL mode or an SSL mode.
* Certificates are issued by _Let's Encrypt_.
* CHORDS uses derived imagees for nginx and certbot. These images add
  a bit of useful functionality, e.g. _bash_ and _nano_. Most importantly,
  they have startup scripts which do some initial configuration based
  on the mode that CHORDS is starting in.
* SSL certificates are created by using nginx and certbot in a standalone mode.
  The ``--no-deps`` switch applied to ``docker-compose run``
  and ``docker-compose up`` can be used to run nginx or certbot
  without starting other dependencies, ie. mysql, influxdb, etc.,
  while still attaching the persistent volumes.
* Nginx will use different configuration files, depending upon
  which mode is in play. Nginx configuration files for all
  modes are built into the nginx container, with some symbols
  designating configurable information.
* The nginx container contains a startup script which will choose which
  nginx configuration to use. It will make variable substitutions
  prior to starting nginx.
* The certbot container startup script will attempt a certificate
  renewal every 6 hours if operating in SSL mode. Otherwise, the
  container will exit.
* The certbot service is run standalone for housekeeping activities,
  such as removing certificates, generating dummy certificates
  (using _openssl_), and so on. This service is used because _docker-compose_
  has it mount the _Let's Encrypt_ related volumes.

## Building

Just a reminder on how to build the CHORDS specific images using ``docker-compose``. The service names are referenced; the _build_
section in _docker-compose.yml_ provides directions for building the image:

```sh
docker-compose build  --no-cache app
docker-compose build  --no-cache  certbot
docker-compose build  --no-cache  nginx
docker-compose build  --no-cache  grafana
docker-compose build  --no-cache  kapacitor
```

_mysql_ is the only service which is run with a stock image. All of the
rest have CHORDS specific images.

## Configuration values

Related docker-compose environment (.env) variables:
  - DOCKER_TAG: set to the desired tag for Docker images. _ssl-cc_
    was used during development; but this will progress through _development_
    to a release number such as _1.1.0_.
  - SSL_ENABLED: "true" / "false".
  - SSL_HOST: The FQDN that accesses this portal. It must be
    operational prior to certificate generation. Can be blank if
    SSL_ENABLED == false.
  - SSL_EMAIL: The email to be associated with the cert. Can be blank
    if SSL_ENABLED == false.
  - CERT_CREATE: if present, nginx knows that it is being used
    only for certificate creation (usually does not need to be in
    the environment; usually just define via command line argument to
    ``docker-compose``)

## Docker volumes

Persistent Docker volumes.

| Volume Name      | Directory            | Function          | Used By                 | Comments |
|-------------------|----------------------|-------------------|-------------------------|----------|
|letsencrypt-etc    | /etc/letsencrypt     | Certificates      |certbot, nginx           | letsencrypt configuration, certificates and renewal details are stored here.|
|letsencrypt-var-log| /var/lib/letsencrypt | Letsencrypt work directory | certbot, nginx | Not sure why this directory needs persistence. |
|letsencrypt-var-log| /var/log/letsencrypt | Letsencrypt logs | certbot |  |
|web-root           | /chords/public       | index.html, error.html, ACME challenge |certbot, nginx| Intially populated by the nginx container with a few static html's (404.html, etc.), it will be is used for the ACME challenge.|

## Certificates

_The following script commands assume that DOCKER_TAG, SSL_HOST and SSL_EMAIL are
set in the environment (and in .env). Make sure that they are defined._

When certificates are to be generated, or replaced:

1. Run oppenssl to create dummy certificates. Use certbot container for this.
```sh
  docker-compose run --no-deps --entrypoint " \
  mkdir -p /etc/letsencrypt/live/$SSL_HOST" certbot

  docker-compose run --no-deps --entrypoint "\
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

## Saving the Certificates (and Other Let's Encrypt Artifacts)

The _Let's Encrypt_ environment, including the certificates will need to be saved/restored during
a CHORDS backup/restore operation:
```sh
docker-compose run --no-deps --rm --entrypoint "/bin/bash -c 'cd /etc/letsencrypt; tar --exclude etc-letsencrypt.tar -cvf etc-letsencrypt.tar .'" nginx

docker cp $(docker-compose ps -q nginx):/etc/letsencrypt/etc-letsencrypt.tar .
```

## Resources
* [Things you want to know about Let's Encrypt](https://simonecarletti.com/blog/2016/02/things-about-letsencrypt/#staging)
* A [good tutorial](https://medium.com/@pentacent/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71)
  on using Docker and Certbot to manage Let's Encrypt services,
  and the [Github repository](https://github.com/wmnnd/nginx-certbot) containing a
  script that is used in the tutorial. Digging into thescript was very helpful.
* [Nginx configuration](https://docs.nginx.com/nginx/admin-guide/basic-functionality/managing-configuration-files), by nginx.com.
* A [free O’Reilley book](https://www.nginx.com/resources/library/complete-nginx-cookbook)
  on nginx, with a basic intro tutorial. Chapter 7 discusses security controls, specifically
  section 7.3 for client-side SSL encryption.
* ACME: Automatic Certificate Management Environment. Certbot is an ACME client.
* Another [intro to Let's Encrypt](https://www.digitalocean.com/community/tutorials/an-introduction-to-let-s-encrypt),
  by Digital Ocean.
