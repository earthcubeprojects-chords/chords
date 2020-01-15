# SSL Integration

## Overview

This describes the process for enabling SSL certificates with CHORDS. The
steps are described as shell commands, to be followed in order. These
commands will eventually be integrated into the _chords_control_ script.

| Step | Svcs | Standalone or Daemon | Action |
|:--:|:------:|:--------------------:|--------|
| 1  | certbot | S | Create a temporary certificate.|
| 2  | certbot | S | Create DH parameters.|
| 3  | nginx   | D | Run a server to handle the ACME challenge.|
| 4  | certbot | S | Erase the temporary certificate.|
| 5  | certbot | S | Use certbot (and Let's Encrypt) to validate using an ACME challenge, and then receive a certificate.|
| 6  | nginx   |   | Shutdown the nginx server.|
| 7  | All     | D | Start CHORDS with the new certificate.|

## Notes

* CHORDS may be run in either a non-SSL mode or an SSL mode.
* Certificates are issued by _Let's Encrypt_. Nginx and certbot containers
  provide the tools for certificate management.
* We use derived images for nginx and certbot. These images add
  a bit of useful functionality, e.g. _bash_ and _nano_. Most importantly,
  they have startup scripts which do some initial configuration based
  on the mode that CHORDS is starting in. _Look at the startup scripts nginx_start.sh and certbot_start.sh_
* SSL certificates are created by using nginx and certbot in a standalone mode.
  The ``--no-deps`` switch applied to ``docker-compose run``
  and ``docker-compose up`` can be used to run nginx or certbot
  without starting other dependencies, ie. mysql, influxdb, etc.,
  while still attaching the docker volumes.
* Nginx will use different configuration files, depending upon
  which mode is in play. Nginx configuration files for all
  modes are built into the nginx image, with some symbols
  designating configurable information.
* The nginx image contains a startup script which will choose which
  nginx configuration to use. It will make variable substitutions
  prior to starting nginx.
* The certbot image startup script will attempt a certificate
  renewal every 6 hours if operating in SSL mode. Otherwise, the
  container will exit.
* _Let's Encrypt_ certficate generation should always be tried in staging mode
  first, to verify that the domain name and everything
  else is working properly.

## Building

Just a reminder on how to build the CHORDS specific images using ``docker-compose``. 
_DOCKER_TAG_ must be defined.
The service names are referenced; the _build_ section in _docker-compose.yml_
provides directions for building the image:

```sh
docker-compose build  --no-cache  app
docker-compose build  --no-cache  certbot
docker-compose build  --no-cache  nginx
docker-compose build  --no-cache  grafana
docker-compose build  --no-cache  kapacitor
```

_mysql_ is the only service in CHORDS which is run with a stock image. All of the
rest have CHORDS specific images.

## Configuration Values

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
    the environment; just define via command line argument to
    ``docker-compose``)

## Docker Volumes

Persistent Docker volumes related to _Let's Encrypt_.

| Volume Name        | Directory            | Function          | Used By                 | Comments |
|--------------------|----------------------|-------------------|:-----------------------:|----------|
|letsencrypt-etc:    | /etc/letsencrypt     | Certificates and renewal info      |certbot, nginx           | letsencrypt configuration, certificates and renewal details are stored here. DH parameters are also saved here.|
|letsencrypt-var-log:| /var/lib/letsencrypt | Letsencrypt work directory | certbot, nginx | Not sure why this directory needs persistence. |
|letsencrypt-var-log:| /var/log/letsencrypt | Letsencrypt logs | certbot |  |
|web-root:           | /chords/public       | index.html, error.html, ACME challenge |certbot, nginx| Intially populated by the nginx container with a few static html's (404.html, etc.), it will be is used for the ACME challenge.|

## Certificate Creation

_The following script commands assume that DOCKER_TAG, SSL_HOST and SSL_EMAIL are
set in the environment (and in .env). Make sure that they are defined._

1. Run oppenssl to **create dummy certificates**. Use the certbot image for this.
   This is required because nginx, when configured for the ACME challenge, will
   not start without there being some certificates present.
```sh
  docker-compose run --no-deps --entrypoint " \
  mkdir -p /etc/letsencrypt/live/$SSL_HOST" certbot

  docker-compose run --no-deps --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:1024 -days 1 \
    -keyout '/etc/letsencrypt/live/$SSL_HOST/privkey.pem' \
    -out '/etc/letsencrypt/live/$SSL_HOST/fullchain.pem' \
    -subj '/CN=localhost'" certbot
```

2. Run oppenssl to **create DH parameters**.
```sh
  docker-compose run --no-deps --entrypoint " \
  mkdir -p /etc/letsencrypt/chords-dhparam" certbot

  docker-compose run --no-deps --entrypoint "\
  openssl dhparam -out /etc/letsencrypt/chords-dhparam/dhparam-2048.pem 2048" certbot
```

3. Provide a **web server for the ACME challenge**.
   Run nginx (as a daemon), in certificate creation mode. 
   nginx, which will be configured for SSL, can start because the 
   dummy certs are present. See _bin/nginx/nginx_cert_create.conf_.

```sh
  docker-compose run -e CERT_CREATE=1 -e SSL_HOST=$SSL_HOST -e SSL_EMAIL=$SSL_EMAIL -p 80:80 -p 443:443 --no-deps -d nginx
```

4. Run certbot with an ``rm`` commands to **erase the dummy certificates**:
```sh
  docker-compose run --no-deps --entrypoint " \
    rm -Rf /etc/letsencrypt/live/$SSL_HOST && \
    rm -Rf /etc/letsencrypt/archive/$SSL_HOST && \
    rm -Rf /etc/letsencrypt/renewal/$SSL_HOST.conf " \
    certbot
```

5. Run certbot to **request a certificate** (“certonly” command) . This causes the following
   to happen:
    1. certbot requests a token from letsencrypt, which it places in the nginx accessible filesystem.
    1. letsencrypt retrieves the token via nginx, succesfully completing the ACME challenge.
    1. the certificate is delivered to certbot, which it places it in the nginx SSL certificate directory.

  *Include ``--staging`` for initial testing, and make sure it succeeds, before getting a real certificate.* Remove ``--staging`` and rerun the command,
  once everything passes. This is to avoid hitting the letsencrypt rate limit, which is
  about 5 measly certificates _per week_!.

```sh
  docker-compose run --no-deps --entrypoint "certbot certonly \
  --webroot -w=/chords/public --email $SSL_EMAIL --agree-tos \
  --no-eff-email --staging -d $SSL_HOST" certbot
```

6. **Shutdown nginx** (and other containers):

```sh
  docker-compose down
```

7. Now **start CHORDS** with a configured SSL certificate:

```sh
  docker-compose up -d
```

## Saving the Certificates (and Other Let's Encrypt Artifacts)

The _Let's Encrypt_ environment, including the certificates may need to be
saved/restored during a CHORDS backup/restore operation:

```sh
docker-compose run --no-deps --rm --entrypoint \
"/bin/bash -c 'cd /etc/letsencrypt; tar --exclude etc-letsencrypt.tar -cvf etc-letsencrypt.tar .'" nginx

docker cp $(docker-compose ps -q nginx):/etc/letsencrypt/etc-letsencrypt.tar .
```

## Certificate Renewal

Certificates are renewed by running ``certbot renew``.
When the CHORDS certbot container is started with _SSL_ENABLED=true",
the _certbot_start.sh_ script does the following:

```sh
  /bin/sh -c 'trap exit TERM; while :; do date; certbot renew \
  --pre-hook "/renew_hooks.sh --pre" --post-hook "/renew_hooks.sh --post"; \
  sleep 6h & wait ${!};
```

A little bit gnarly, but it is just running ``certbot renew`` every 24 hours, attempting to renew the certificates. It will only succeed when certificates are
ready to be renewed.

``--pre-hook`` and ``--post-hook`` specify scripts to be run before and
after the renewal. _They will only be run if a certificate is ready for
renewal, and ``--post-hook`` will only be run after a successful renewal_.

The --post-hook script (``renew_hooks.sh --post``) will force an
nginx restart, by having docker run the reload command in the neighboring
nginx container:

```sh
docker exec chords_nginx /usr/sbin/nginx -s reload
```

This is possible because we installed docker in the certbot container,
and share the docker socket between the host, and the nginx and certbot containers. Note: the Rails application uses a similar technique to
acccess _influxdb_ for database backups.

It's tricky to test the hook scripts, because they normally don't run.
However, you can run the certbot renew command with ``--force-renew``, to
force a renewal. But this should be used judicously, since you will
run into the the same limits (5 per week) as for certificate creation.

## Debugging

- See these [debugging tools](https://certbot.eff.org/faq#what-tools-can-i-use-for-debugging-my-site-s-https-configuration) when you are having problems.

- It is very useful to run a shell in an image, with the volumes mounted,
  but not starting dependent services. This allows you to see exactly what
  the container is mounting. Use the ``--no-deps`` flag, e.g.:

```sh
docker-compose run --no-deps --entrypoint /bin/bash certbot
docker-compose run --no-deps --entrypoint /bin/bash nginx
docker-compose run --no-deps --entrypoint /bin/bash app
```

## Resources
* [Things you want to know about Let's Encrypt](https://simonecarletti.com/blog/2016/02/things-about-letsencrypt/#staging).
* A [good tutorial](https://medium.com/@pentacent/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71)
  on using Docker and Certbot to manage Let's Encrypt services,
  and the [Github repository](https://github.com/wmnnd/nginx-certbot) containing a
  script that is used in the tutorial. Digging into the script was very helpful.
* [Nginx configuration](https://docs.nginx.com/nginx/admin-guide/basic-functionality/managing-configuration-files), by nginx.com.
* Nginx [location blocks](https://www.digitalocean.com/community/tutorials/understanding-nginx-server-and-location-block-selection-algorithms).
* A [free O’Reilley book](https://www.nginx.com/resources/library/complete-nginx-cookbook)
  on nginx, with a basic intro tutorial. Chapter 7 discusses security controls, specifically
  section 7.3 for client-side SSL encryption.
* ACME: Automatic Certificate Management Environment. Certbot is an ACME client.
* Another [intro to Let's Encrypt](https://www.digitalocean.com/community/tutorials/an-introduction-to-let-s-encrypt) 
  by Digital Ocean.
