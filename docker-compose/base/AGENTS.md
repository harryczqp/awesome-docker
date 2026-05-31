<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# base

## Purpose
Collection of foundational infrastructure services providing core capabilities used by other application services in the docker-compose ecosystem. Includes relational databases (MySQL, PostgreSQL), in-memory store (Redis), reverse proxies (Nginx, OpenResty), and a business application server (Tuanmiao/Yudao).

## Key Files
| File | Description |
|------|-------------|
| `*/docker-compose.yml` | Service definition for each base service |

## Subdirectories
| Directory | Purpose |
|-----------|---------|
| `mysql/` | MySQL 5.7 database server (see `mysql/AGENTS.md`) |
| `nginx/` | Nginx 1.31 reverse proxy (see `nginx/AGENTS.md`) |
| `openresty/` | OpenResty with Lua/WAF support (see `openresty/AGENTS.md`) |
| `postgres/` | PostgreSQL 18 database server (see `postgres/AGENTS.md`) |
| `redis/` | Redis 8 in-memory data store (see `redis/AGENTS.md`) |
| `tuanmiao/` | Tuanmiao/Yudao business application server (see `tuanmiao/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- These are infrastructure services; start them before dependent applications.
- All services use `network_mode: host` and may conflict on standard ports (3306, 5432, 6379, 80).
- Configuration is mounted from `/etc/configs/<service>/` on the host.

### Testing Requirements
- Verify service health with built-in health checks: `docker compose ps`.
- Test database connectivity from dependent containers.

### Common Patterns
- Host networking mode for zero NAT overhead.
- Named volumes for persistent data.
- Health checks on all stateful services.
- Resource limits (mem_limit, cpus) on proxy services.

## Dependencies

### Internal
- None — these are the base layer.

### External
- `mysql:5.7`
- `nginx:1.31.0-alpine`
- `openresty/openresty:alpine`
- `postgres:18-alpine`
- `redis:8-alpine`
- `crpi-c022qgsomszpe1m9.cn-shanghai.personal.cr.aliyuncs.com/tuanmiao/yudao-server:latest`

<!-- MANUAL: -->
