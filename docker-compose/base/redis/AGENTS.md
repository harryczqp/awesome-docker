<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# redis

## Purpose
Redis 8 Alpine in-memory data store with AOF persistence, password authentication, and health checking via `redis-cli ping`. Configured with RDB snapshots every 60 seconds if at least 1 key changed, and append-only file syncing every second.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yml` | Redis service definition with AOF, auth, and health check |

## Subdirectories
None.

## For AI Agents

### Working In This Directory
- Requires `.env` file with `REDIS_PASSWORD` and optional `TZ`.
- Data persists in named volume `data` mapped to `/data`.
- Uses `network_mode: host` on port 6379; ensure no conflicts.
- `REDISCLI_AUTH` is set so `redis-cli` inside the container does not require manual password entry.

### Testing Requirements
- Health check runs every 10s: `redis-cli ping`.
- Verify with: `docker compose ps` and `docker compose logs -f redis`.
- Test auth: `redis-cli -a ${REDIS_PASSWORD} ping` from host.

### Common Patterns
- `appendonly yes` with `appendfsync everysec` for durability/performance balance.
- `--save 60 1` for periodic RDB snapshots.
- `requirepass` for basic authentication.

## Dependencies

### Internal
- None.

### External
- `redis:8-alpine`

<!-- MANUAL: -->
