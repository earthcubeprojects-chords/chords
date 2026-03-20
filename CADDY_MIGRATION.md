# Plan: Convert CHORDS from nginx+certbot to Caddy

## Context

CHORDS currently uses nginx as a reverse proxy with a separate certbot container for SSL certificate management. The SSL workflow is complex: dummy cert creation, DH param generation, a special "CERT_CREATE" nginx startup mode, and manual ACME challenge orchestration via `chords_control`. Caddy eliminates almost all of this complexity — it handles ACME challenges and certificate renewal automatically on first startup, with no external certbot required. This conversion simplifies the SSL workflow dramatically, reduces the container count by one, and replaces the five Let's Encrypt-related volumes with two Caddy-managed volumes.

## Files to Create

### `bin/caddy/Caddyfile.ssl_off`
HTTP-only mode. Serves static files from `/chords/public` with pass-through to `app:3042`. Includes security headers. Log rolling built into Caddy's `log` directive (10MB, keep 10).

### `bin/caddy/Caddyfile.ssl_on`
Two site blocks:
1. `http://{$SSL_HOST}` — handles `/measurements/url_create*` (HTTP exception for low-power IoT devices), redirects everything else to HTTPS
2. `https://{$SSL_HOST}` — full HTTPS with auto-cert, static file serving, reverse proxy, security headers

Caddy natively reads `{$SSL_HOST}` and `{$SSL_EMAIL}` from the container environment — no `envsubst` needed.

### `bin/caddy/caddy_start.sh`
Selects Caddyfile based on `SSL_ENABLED` env var (same pattern as `nginx_start.sh`). Copies selected file to `/etc/caddy/Caddyfile`, then `exec caddy run --config /etc/caddy/Caddyfile`. No cron, no logrotate, no variable substitution needed.

### `bin/caddy/Dockerfile`
```dockerfile
FROM caddy:2-alpine
RUN apk add --no-cache bash && mkdir -p /var/log/caddy
COPY bin/caddy/caddy_start.sh /tmp/
RUN chmod 755 /tmp/caddy_start.sh
COPY bin/caddy/Caddyfile.ssl_off /tmp/
COPY bin/caddy/Caddyfile.ssl_on /tmp/
EXPOSE 80 443
CMD ["/tmp/caddy_start.sh"]
```

## Files to Modify

### `docker-compose.yml`
- Replace `nginx` service (image `earthcubechords/chords_nginx`) and `certbot` service with a single `caddy` service:
  ```yaml
  caddy:
    container_name: chords_caddy
    image: earthcubechords/chords_caddy:${DOCKER_TAG}
    volumes:
      - caddy-log:/var/log/caddy
      - caddy-data:/data          # Caddy's cert storage
      - caddy-config:/config      # Caddy's config persistence
    environment:
      - SSL_ENABLED=${SSL_ENABLED}
      - SSL_HOST=${SSL_HOST}
      - SSL_EMAIL=${SSL_EMAIL}
    ports:
      - ${CHORDS_HTTP_PORT:-80}:80
      - 443:443
    depends_on:
      - app
  ```
- Remove volumes: `nginx-log`, `letsencrypt-etc`, `letsencrypt-var-lib`, `letsencrypt-log`, `acme-challenge`
- Add volumes: `caddy-log`, `caddy-data`, `caddy-config`
- Update header comment (remove references to `chords_nginx` and `chords_certbot`)

### `docker-compose-build.yml`
- Remove `nginx` and `certbot` build entries
- Add:
  ```yaml
  caddy:
    image: earthcubechords/chords_caddy:${DOCKER_TAG}
    build:
      context: .
      dockerfile: ./bin/caddy/Dockerfile
  ```

### `chords_control` — `ChordsSSL` class
The class needs significant simplification. The ACME challenge is handled automatically by Caddy on first startup; the entire multi-step `create_cert` ceremony becomes unnecessary:
- **`create_cert`**: Rewrite to simply verify DNS is resolvable (`host_dns()`), then inform the user to start CHORDS normally — Caddy will obtain the cert automatically.
- **`make_dummy_cert`**: Delete (certbot-specific, not needed).
- **`make_dh_params`**: Delete (nginx DH params, not needed by Caddy).
- **`remove_certs`**: Rewrite to remove the `caddy-data` Docker volume (`docker volume rm chords_caddy-data`) instead of shelling into certbot.
- **`check_cert`**: Rewrite to use Python's `ssl` module to connect to `SSL_HOST:443` and read cert dates — no certbot container needed.
- **`request_cert`**: Delete (replaced by Caddy auto-cert).
- **`start_nginx` / `stop_nginx`**: Delete or stub (no longer needed for cert creation).
- **`cert_inquire`**: Delete (was certbot-specific).
- Container name references: `chords_nginx` → `chords_caddy`, remove `chords_certbot` from running-checks.

The `ChordsSSL` class was significantly simplified:

- **Deleted**: `make_dummy_cert`, `make_dh_params`, `remove_certs`, `request_cert`,
  `start_nginx`, `stop_nginx`, `cert_inquire`
- **Rewritten `create_cert`**: Now just prints instructions — Caddy handles cert creation
  automatically on first startup with `SSL_ENABLED=true`
- **Rewritten `check_cert`**: Uses Python's `ssl`/`socket` modules to probe the live
  certificate at `SSL_HOST:443`; no longer shells into the certbot container


### `bin/ssl/ssl.md`
Rewrite to document the simplified SSL process: set `SSL_ENABLED=true`, `SSL_HOST`, `SSL_EMAIL` in `.env`, then `docker-compose -p chords up -d`. Caddy handles everything.

## Volume Changes

| Old volume | New volume | Purpose |
|------------|------------|---------|
| `nginx-log` | `caddy-log` (`/var/log/caddy`) | Access logs |
| `letsencrypt-etc` | `caddy-data` (`/data`) | Certificate storage |
| `letsencrypt-var-lib` | `caddy-config` (`/config`) | Runtime config persistence |
| `letsencrypt-log` | *(removed)* | No longer needed |
| `acme-challenge` | *(removed)* | Caddy handles ACME internally |

## Key Behavioral Equivalences

| nginx behavior | Caddy equivalent |
|----------------|-----------------|
| `try_files $uri/index.html $uri @chords_app` | `file_server { pass_thru }` + `reverse_proxy` |
| Port 80 `/measurements/url_create` HTTP exception | `http://{$SSL_HOST}` block with `handle /measurements/url_create*` |
| ACME challenge at `/.well-known/acme-challenge/` | Built-in (Caddy handles automatically) |
| certbot renew every 24h | Built-in (Caddy auto-renews ~30 days before expiry) |
| `nginx -s reload` after cert renewal | Not needed (Caddy handles live cert rotation) |
| logrotate hourly, 10MB, keep 10 | `log { output file ... { roll_size 10mb; roll_keep 10 } }` |
| TLS 1.0/1.1/1.2 + custom ciphers | Caddy defaults: TLS 1.2+ with modern ciphers (security improvement) |

## SSL_EMAIL Note

Caddy only uses `SSL_EMAIL` when registering a new ACME account with Let's Encrypt on first
startup. Changing it afterward has no effect on existing certificates or renewals. To associate
a new email with the account, remove the `caddy-data` volume before restarting:

```sh
docker volume rm chords_caddy-data
```

This forces a fresh account registration and new certificate request on next startup.

## Migration for Existing Users

Users with existing Let's Encrypt certs in `letsencrypt-etc` volume: Caddy will request a fresh cert on first startup. Let's Encrypt rate limit is 5 duplicate certs per 7 days per domain — rarely an issue for CHORDS users. After confirming Caddy is working, old volumes can be removed:
```
docker volume rm chords_letsencrypt-etc chords_letsencrypt-var-lib chords_acme-challenge chords_letsencrypt-log
```

## Image Naming

The new image is `earthcubechords/chords_caddy` (replacing `earthcubechords/chords_nginx`).
Users who follow the `chords_control --renew` update path automatically get the new
`docker-compose.yml` with the correct image name.

To build and push:

```sh
docker-compose -f docker-compose.yml -f docker-compose-build.yml build --no-cache caddy
docker push earthcubechords/chords_caddy:${DOCKER_TAG}
```

## Building and Pushing chords_caddy (on AlmaLinux 9 without Docker)

AlmaLinux 9 ships with Podman and Buildah instead of Docker CE. The following process was used to build and push the `chords_caddy` image.

### Install tools

```sh
sudo dnf install -y podman buildah
```

### Fix the Dockerfile base image

Buildah defaults to the Red Hat registry, so the bare `FROM caddy:2-alpine` will fail. Use the fully-qualified name:

```dockerfile
FROM docker.io/library/caddy:2-alpine
```

### Build the image

Run from the **repo root** (not from `bin/caddy/`) so that COPY paths resolve correctly:

```sh
cd /home/martinc/chords
buildah bud -f bin/caddy/Dockerfile -t chords_caddy .
```

### Tag the image

```sh
docker tag chords_caddy docker.io/earthcubechords/chords_caddy:1.1.0-rc7
```

(`docker` is emulated by Podman on AlmaLinux 9 — the commands are identical.)

### Log in and push

Login must use the fully-qualified registry name or credentials won't match:

```sh
docker login docker.io
docker push docker.io/earthcubechords/chords_caddy:1.1.0-rc7
```

### Duplicate an existing image with a new tag (no rebuild)

To retag an existing Docker Hub image without rebuilding:

```sh
docker pull docker.io/earthcubechords/chords:1.1.0-rc6
docker tag earthcubechords/chords:1.1.0-rc6 docker.io/earthcubechords/chords:1.1.0-rc7
docker push docker.io/earthcubechords/chords:1.1.0-rc7
```

### List images in a Docker Hub organization

```sh
curl -s "https://hub.docker.com/v2/repositories/earthcubechords/?page_size=100" | python3 -m json.tool | grep '"name"'
```

### Inspect a Docker volume from inside a container

```sh
docker run --rm -it -v chords_caddy-data:/data alpine sh
```

## Verification

1. Build: `docker-compose -f docker-compose.yml -f docker-compose-build.yml build caddy`
2. Test HTTP mode: Set `SSL_ENABLED=false`, start stack, verify `http://localhost` proxies to Rails app, static files serve from `/chords/public`
3. Test HTTPS mode: Set `SSL_ENABLED=true` with a real `SSL_HOST`, start stack, verify Caddy obtains cert and `https://SSL_HOST` works
4. Verify IoT exception: `curl http://SSL_HOST/measurements/url_create` returns 200 (not redirect) when SSL is on
5. Verify security headers: `curl -I https://SSL_HOST` shows X-Frame-Options, X-Content-Type-Options, etc.
6. Verify log rolling configured (check Caddyfile applied correctly)
7. Test `chords_control --ssl` commands work with new simplified ChordsSSL implementation
