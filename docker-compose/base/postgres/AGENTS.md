<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# postgres

## Purpose
PostgreSQL 18 Alpine database server with health checking via `pg_isready`. Configured with environment-driven credentials, a named volume for data persistence, and host networking on the default PostgreSQL port.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yml` | PostgreSQL service definition with health check and named volume |

## Subdirectories
None.

## For AI Agents

### Working In This Directory
- Requires `.env` file with `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`, and optional `TZ`.
- Data persists in named volume `data` mapped to `/var/lib/postgresql/data`.
- Uses `network_mode: host` on port 5432; ensure no conflicts.

### Testing Requirements
- Health check runs every 10s: `pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}`.
- Verify with: `docker compose ps` and `docker compose logs -f postgres`.

### Common Patterns
- `env_file: ./.env` for credential and timezone injection.
- `PGDATA` explicitly set to control data directory.
- `ulimits` raised to 100000 for high-connection workloads.

## Dependencies

### Internal
- None.

### External
- `postgres:18-alpine`

<!-- MANUAL: -->
