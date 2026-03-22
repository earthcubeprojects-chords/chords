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

## Grafana via Caddy

Grafana is proxied through Caddy on its own port (`GRAFANA_HTTP_PORT`, default 3000), giving
it HTTPS when SSL is enabled while preserving backward compatibility with existing port 3000
references.

### How it works

- **SSL on**: `https://SSL_HOST:3000/` → `grafana:3000` (HTTPS via Caddy's cert for `SSL_HOST`)
- **SSL off**: `http://host:3000/` → `grafana:3000` (plain HTTP passthrough)
- Caddy owns port 3000 and proxies to the Grafana container; Grafana is not directly exposed

### Changes made

**`Caddyfile.ssl_off`** — port-based site block at the end:
```
:{$GRAFANA_HTTP_PORT} {
    reverse_proxy grafana:{$GRAFANA_HTTP_PORT}
}
```

**`Caddyfile.ssl_on`** — port-based site block using the SSL cert:
```
{$SSL_HOST}:{$GRAFANA_HTTP_PORT} {
    tls {$SSL_EMAIL}
    reverse_proxy grafana:{$GRAFANA_HTTP_PORT}
}
```

**`docker-compose.yml`** — caddy service gets the Grafana port exposed:
```yaml
ports:
  - ${CHORDS_HTTP_PORT:-80}:80
  - 443:443
  - ${GRAFANA_HTTP_PORT:-3000}:${GRAFANA_HTTP_PORT:-3000}
environment:
  - GRAFANA_HTTP_PORT=${GRAFANA_HTTP_PORT}
```

**`docker-compose.yml`** — grafana service: no sub-path configuration needed; Grafana runs
normally at its root path, accessed through Caddy's port proxy.

**`_topnav.html.haml`** — Visualization link uses the same protocol as the current request
with the Grafana port:
```haml
- grafana_url = "#{request.protocol}#{request.host}:#{ENV['GRAFANA_HTTP_PORT'] || '3000'}/"
```
This gives `https://mysite.com:3000/` in SSL mode and `http://mysite.com:3000/` otherwise.

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

## Building and Pushing chords_caddy (on AlmaLinux 9)

AlmaLinux 9 ships with Podman instead of Docker CE. Podman provides a `docker` compatibility
shim, so standard `docker` and `docker compose` commands work — but must be run with `sudo`
to use rootful Podman, which avoids registry resolution and socket permission issues.

### Install tools

```sh
sudo dnf install -y podman
```

### Fix the Dockerfile base image

Podman defaults to the Red Hat registry, so the bare `FROM caddy:2-alpine` will fail. Use the fully-qualified name:

```dockerfile
FROM docker.io/library/caddy:2-alpine
```

### Build the image

Use `buildah` directly with the fully-qualified `docker.io/` tag to avoid a separate tag step.
Run from the **repo root**:

```sh
sudo buildah bud --no-cache -f bin/caddy/Dockerfile -t docker.io/earthcubechords/chords_caddy:${DOCKER_TAG} .
```

Using `docker.io/` in the tag means buildah stores the image under `docker.io/` rather than
`localhost/`, so no re-tagging is needed before pushing.

To build the main chords app image:

```sh
sudo buildah bud --no-cache -f Dockerfile -t docker.io/earthcubechords/chords:${DOCKER_TAG} .
```

### Log in and push

```sh
sudo docker login docker.io
sudo docker push docker.io/earthcubechords/chords_caddy:${DOCKER_TAG}
sudo docker push docker.io/earthcubechords/chords:${DOCKER_TAG}
```

### Duplicate an existing image with a new tag (no rebuild)

To retag an existing Docker Hub image without rebuilding:

```sh
sudo docker pull earthcubechords/chords:1.1.0-rc6
sudo docker tag earthcubechords/chords:1.1.0-rc6 earthcubechords/chords:1.1.0-rc7
sudo docker push earthcubechords/chords:1.1.0-rc7
```

### List images in a Docker Hub organization

```sh
curl -s "https://hub.docker.com/v2/repositories/earthcubechords/?page_size=100" | python3 -m json.tool | grep '"name"'
```

### Inspect a Docker volume from inside a container

```sh
sudo docker run --rm -it -v chords_caddy-data:/data alpine sh
```

## Workflow Review

The end-to-end workflow for building, publishing, and deploying a new `chords_caddy` release:

### 1. Edit and commit source changes

Make changes to files under `bin/caddy/` (Caddyfile, Dockerfile, startup script), commit, and push to the repo.

### 2. Build the images

From the repo root. Use the fully-qualified `docker.io/` tag so no re-tagging is needed before pushing:

```sh
sudo buildah bud --no-cache -f bin/caddy/Dockerfile -t docker.io/earthcubechords/chords_caddy:${DOCKER_TAG} .
sudo buildah bud --no-cache -f Dockerfile -t docker.io/earthcubechords/chords:${DOCKER_TAG} .
```

### 3. Push to Docker Hub

```sh
sudo docker login docker.io
sudo docker push docker.io/earthcubechords/chords_caddy:${DOCKER_TAG}
sudo docker push docker.io/earthcubechords/chords:${DOCKER_TAG}
```

### 4. Deploy

On the target host, with a populated `.env` file and `docker-compose.yml` in the working directory:

```sh
sudo docker compose -p chords pull
sudo docker compose -p chords up -d
```

Or via `chords_control`:

```sh
sudo python3 chords_control --update
sudo python3 chords_control --run
```

### 5. Verify

```sh
sudo python3 chords_control --status
curl -I http://localhost
```

---

### Notes

- All `docker` commands require `sudo` on AlmaLinux 9 (rootful Podman).
- `docker` on AlmaLinux 9 is Podman with a Docker compatibility shim — behavior is identical.
- Suppress the Podman emulation notice: `sudo touch /etc/containers/nodocker`
- `DOCKER_TAG` is set in `.env` and controls which image tag is pulled and run.
- To retag an existing image without rebuilding, see the "Duplicate an existing image" section above.

## Verification

1. Build: `docker-compose -f docker-compose.yml -f docker-compose-build.yml build caddy`
2. Test HTTP mode: Set `SSL_ENABLED=false`, start stack, verify `http://localhost` proxies to Rails app, static files serve from `/chords/public`
3. Test HTTPS mode: Set `SSL_ENABLED=true` with a real `SSL_HOST`, start stack, verify Caddy obtains cert and `https://SSL_HOST` works
4. Verify IoT exception: `curl http://SSL_HOST/measurements/url_create` returns 200 (not redirect) when SSL is on
5. Verify security headers: `curl -I https://SSL_HOST` shows X-Frame-Options, X-Content-Type-Options, etc.
6. Verify log rolling configured (check Caddyfile applied correctly)
7. Test `chords_control --ssl` commands work with new simplified ChordsSSL implementation
