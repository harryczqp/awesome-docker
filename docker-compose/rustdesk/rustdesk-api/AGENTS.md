<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# rustdesk-api

## Purpose
Open-source RustDesk API server providing web-based user and device management for RustDesk deployments. Exposes port 21114 on bridge network and persists SQLite data in a named volume.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | RustDesk API server service definition |

## Subdirectories
None.

## For AI Agents

### Working In This Directory
- Uses bridge networking with explicit port mapping `21114:21114`.
- Optional environment variables: `CSRF_TRUSTED_ORIGINS`, `ID_SERVER`.
- Data persists in named volume `rustdesk_api_data` mapped to `/rustdesk-api-server/db`.
- Image tag defaults to `latest` via `IMAGE_TAG` environment variable.

### Testing Requirements
- Access the web UI at `http://<host>:21114`.
- Verify SQLite database is writable inside the container.
- Check logs: `docker compose logs -f rustdesk-api-server`.

### Common Patterns
- Bridge network with explicit port exposure (unlike host-network core services).
- Named volume for SQLite database persistence.
- Timezone mounted from host for accurate timestamps.

## Dependencies

### Internal
- `rustdesk/` — core hbbs/hbbr servers this API manages.

### External
- `ghcr.io/kingmo888/rustdesk-api-server:${IMAGE_TAG:-latest}`

<!-- MANUAL: -->
