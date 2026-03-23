# CHORDS Release Notes

## 1.1.0-rc7

### Web Server: Migration from nginx to Caddy
The reverse proxy has been replaced with [Caddy](https://caddyserver.com/), which provides automatic HTTPS certificate management via Let's Encrypt — no manual certificate configuration required. HTTP traffic is automatically redirected to HTTPS when SSL is enabled.

### Grafana HTTPS Support
Grafana is now served through Caddy with full HTTPS support. The Grafana port (configurable via `GRAFANA_HTTP_PORT`) is proxied securely, and visualization links in the Rails app adapt automatically based on whether SSL is enabled.

### Service Reliability Improvements
- Health checks added for MySQL and InfluxDB to ensure dependent services wait for them to be ready before starting.
- Restart policies added to all services to automatically recover from failures.
- InfluxDB file descriptor limit raised to 65,536 to prevent connection exhaustion as the time-series database grows.

### Removed: Kapacitor Support
Legacy Kapacitor integration has been removed. The Kapacitor service is no longer started or managed by CHORDS.

### chords_control Improvements
- Removed Podman support — Docker is now the only supported container runtime, simplifying the control script.
- Updated to use `docker compose` (v2 plugin syntax) instead of the deprecated `docker-compose`.
- Improved command logging.

### Documentation
- Updated all documentation links to point to the official CHORDS website.
- Updated the CHORDS logo link.
- Added notes to the restore process about updating settings when upgrading to a new release.
