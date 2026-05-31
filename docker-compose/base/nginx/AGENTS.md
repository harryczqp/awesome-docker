<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# nginx

## Purpose
Nginx 1.31.0 Alpine reverse proxy and static web server. Configured with host networking, resource limits (512M memory, 1.0 CPU), and volume mounts for configuration, SSL certificates, static HTML, and log files.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yml` | Nginx service definition with resource limits and volume mounts |

## Subdirectories
None.

## For AI Agents

### Working In This Directory
- Host paths must exist before starting: `/var/log/nginx`, `/etc/configs/nginx/{conf.d,html,ssl}`.
- Ownership: `chown -R 101:101 /var/log/nginx` (nginx user inside container).
- Uses `network_mode: host` on ports 80/443; ensure no conflicts.

### Testing Requirements
- Validate nginx config syntax before reloading: `nginx -t` inside container.
- Verify with: `docker compose ps` and `docker compose logs -f nginx`.

### Common Patterns
- Static files served from `/usr/share/nginx/html`.
- SSL certificates mounted read-only from host.
- JSON-file logging with 50m max size and 5 file rotation.

## Dependencies

### Internal
- None.

### External
- `nginx:1.31.0-alpine`

<!-- MANUAL: -->
