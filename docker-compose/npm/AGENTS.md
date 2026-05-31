<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# npm

## Purpose
Nginx Proxy Manager (NPM) deployment providing a web UI for managing reverse proxies, SSL certificates, and redirections. Includes a custom home dashboard (`home/`) with HTML/JS/CSS frontend assets.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | Nginx Proxy Manager service definition |

## Subdirectories
| Directory | Purpose |
|-----------|---------|
| `home/` | Custom dashboard frontend — HTML, JS, CSS assets (see `home/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- NPM web UI typically available on port 81 (admin) and 80/443 (proxy).
- Uses `network_mode: host`; ensure no port conflicts.
- Data and Let's Encrypt certificates persist in named volume `data`.

### Testing Requirements
- Access the admin UI at `http://<host>:81`.
- Verify proxy hosts and SSL certificates are functioning.

### Common Patterns
- Named volume for both application data and Let's Encrypt storage.
- Host networking for direct port binding.

## Dependencies

### Internal
- None.

### External
- `docker.io/jc21/nginx-proxy-manager:latest`

<!-- MANUAL: -->
