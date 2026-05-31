<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# moontvplus

## Purpose
MoonTV Plus is an enhanced media streaming platform with three services: a core web application (port 3001), a Kvrocks key-value store for data persistence, and an LX Sync Server (port 9527) for music synchronization. The services communicate over a dedicated bridge network `moontv-network`.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yml` | Docker Compose configuration for moontvplus, kvrocks, and lx-sync-server |

## For AI Agents

### Working In This Directory
- Modify the docker-compose file to adjust ports, volumes, or environment variables
- Ensure volume paths are absolute or properly relative to the project
- Do not change the service name without updating dependent references
- Services communicate over the `moontv-network` bridge network
- The core service depends on kvrocks; ensure kvrocks starts first
- Default credentials are USERNAME=admin / PASSWORD=admin — change in production
- LX Sync Server provides music sync capabilities with separate data, logs, cache, and music volumes

### Testing Requirements
- Validate with: `docker compose -f docker-compose.yml config`
- Check that exposed ports do not conflict with other services in this repo
- Verify all three services can communicate over `moontv-network`

### Common Patterns
- Standard Docker Compose single-service or multi-service stack
- Environment variables may be defined inline or in a separate `.env` file

## Dependencies

### External
- `ghcr.io/mtvpls/moontvplus:latest` — MoonTV Plus media streaming web application
- `apache/kvrocks` — Redis-compatible key-value store for data persistence
- `xcq0607/lxserver:latest` — LX music synchronization server

<!-- MANUAL: -->
