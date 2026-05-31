<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# rustdesk-pro

## Purpose
RustDesk API Server Pro — an advanced management API for RustDesk with SQLite backend, SMTP support, admin authentication, and device check jobs. Configured via a host-mounted `server.yaml` file.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | RustDesk API Server Pro service definition |
| `server.yaml` | Server configuration — database, HTTP, SMTP, jobs |

## Subdirectories
None.

## For AI Agents

### Working In This Directory
- Requires `server.yaml` on the host before starting.
- Default admin credentials: `admin` / `admin` (change before production use).
- Uses bridge networking with port mapping `12345:8080`.
- SQLite database is created at `./server.db` relative to the config.

### Testing Requirements
- Access the API at `http://<host>:12345`.
- Verify `server.yaml` is readable inside the container.
- Check logs: `docker compose logs -f rustdesk-api-server-pro`.

### Common Patterns
- Config-driven deployment via mounted YAML file.
- Bridge network with explicit port mapping.
- Debug mode enabled by default in `server.yaml`.

## Dependencies

### Internal
- `rustdesk/` — core hbbs/hbbr servers this API manages.

### External
- `ghcr.io/lantongxue/rustdesk-api-server-pro:latest`

<!-- MANUAL: -->
