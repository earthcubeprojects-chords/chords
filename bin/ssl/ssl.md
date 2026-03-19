# SSL Integration

## Overview

CHORDS uses [Caddy](https://caddyserver.com/) as its reverse proxy. Caddy handles SSL
certificate management automatically via Let's Encrypt — no manual certificate creation
steps are needed.

## Quick Start

1. Set the following variables in your `.env` file:
   ```
   SSL_ENABLED=true
   SSL_HOST=your.domain.example.com
   SSL_EMAIL=you@example.com
   ```

2. Start CHORDS normally:
   ```sh
   docker-compose -p chords up -d
   ```

That's it. Caddy will contact Let's Encrypt, complete the ACME challenge, obtain a
certificate for `SSL_HOST`, and begin serving HTTPS traffic — all on first startup.
Caddy also renews certificates automatically before they expire.

## Prerequisites

- **DNS must be configured** before starting CHORDS with SSL enabled. The domain name in
  `SSL_HOST` must resolve to the public IP address of this server. Caddy cannot obtain a
  certificate if Let's Encrypt cannot reach your server via that hostname.

- **Port 80 and 443 must be open** on your firewall/security group.

- **Let's Encrypt rate limits**: You can obtain at most 5 certificates per domain per 7
  days. If you are testing, avoid restarting CHORDS repeatedly in quick succession.

## Configuration Variables

| Variable      | Description                                                        |
|---------------|--------------------------------------------------------------------|
| `SSL_ENABLED` | `true` to enable HTTPS, `false` for HTTP-only                     |
| `SSL_HOST`    | The fully-qualified domain name (FQDN) for the CHORDS portal      |
| `SSL_EMAIL`   | Email address associated with the Let's Encrypt account           |

> **Note on changing `SSL_EMAIL`:** Caddy only uses `SSL_EMAIL` when registering a new ACME
> account with Let's Encrypt on first startup. Changing it afterward has no effect on existing
> certificates or renewals. To associate a new email with the account, remove the `caddy-data`
> volume (`docker volume rm chords_caddy-data`) before restarting — this forces a fresh account
> registration and new certificate request.

## HTTP Exception for IoT Devices

Low-power IoT devices that cannot use HTTPS may still send measurements over HTTP.
The path `/measurements/url_create*` is served over plain HTTP even when SSL is enabled.
All other HTTP traffic is redirected to HTTPS.

## Migrating from the Old nginx+certbot Setup

If you are upgrading from a CHORDS installation that used nginx and certbot:

1. Stop CHORDS: `docker-compose -p chords down`
2. Pull the new images: `docker-compose pull`
3. Start CHORDS: `docker-compose -p chords up -d`

Caddy will obtain a fresh certificate automatically. Once you have confirmed that HTTPS
is working correctly, you may remove the old letsencrypt-related Docker volumes:

```sh
docker volume rm chords_letsencrypt-etc chords_letsencrypt-var-lib \
                 chords_letsencrypt-log chords_acme-challenge
```

These volumes are no longer used and are safe to delete after Caddy is working.

## Building the Caddy Image

To build the Caddy image from source (run from the top-level CHORDS directory):

```sh
docker-compose -f docker-compose.yml -f docker-compose-build.yml build --no-cache caddy
```

## Debugging

To inspect what Caddy is doing, check its logs:

```sh
docker logs chords_caddy
```

Or tail the access log inside the container:

```sh
docker exec chords_caddy tail -f /var/log/caddy/access.log
```

To open a shell in the Caddy container:

```sh
docker exec -it chords_caddy /bin/sh
```

## Resources

* [Caddy documentation](https://caddyserver.com/docs/)
* [Caddy automatic HTTPS](https://caddyserver.com/docs/automatic-https)
* [Let's Encrypt](https://letsencrypt.org/)
* [Let's Encrypt rate limits](https://letsencrypt.org/docs/rate-limits/)
