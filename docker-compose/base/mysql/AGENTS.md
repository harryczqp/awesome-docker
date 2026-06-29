<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# mysql

## Purpose
MySQL 5.7 database server providing persistent relational data storage. Configured with utf8mb4 character set, 300 max connections, and a health check via mysqladmin ping. Uses host networking and a named Docker volume for data persistence.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yml` | MySQL 5.7 service definition with health check and volume |

## Subdirectories
None.

## For AI Agents

### Working In This Directory
- Requires `.env` file with `MYSQL_ROOT_PASSWORD` and optional `TZ`.
- Data persists in named volume `data` mapped to `/var/lib/mysql`.
- Uses `network_mode: host` on port 3306; ensure no other MySQL instance is bound.

### Testing Requirements
- Health check runs every 10s: `mysqladmin ping -h localhost -uroot -p${MYSQL_ROOT_PASSWORD}`.
- Verify with: `docker compose ps` and `docker compose logs -f mysql`.

### Common Patterns
- `env_file: ./.env` for credential injection.
- Command-line flags for charset and connection tuning.
- `ulimits` raised to 100000 for high-connection workloads.

## Dependencies

### Internal
- None.

### External
- `mysql:5.7`

<!-- MANUAL: -->
