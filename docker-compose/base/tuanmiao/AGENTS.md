<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# tuanmiao

## Purpose
Tuanmiao (Yudao) business application server — a Chinese all-in-one business management platform. Runs as a single container with host networking on port 48080, health-checked via `nc -z localhost 48080`.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yml` | Yudao server service definition with health check |

## Subdirectories
None.

## For AI Agents

### Working In This Directory
- Uses `network_mode: host` on port 48080; ensure no conflicts.
- Optional `.env` with `TZ` (defaults to Asia/Shanghai).
- Data persists in named volume `data`.

### Testing Requirements
- Health check runs every 10s on port 48080.
- Verify with: `docker compose ps` and `docker compose logs -f yudao`.

### Common Patterns
- Custom Aliyun registry image for the Yudao server.
- JSON-file logging with 100m max size.

## Dependencies

### Internal
- None.

### External
- `crpi-c022qgsomszpe1m9.cn-shanghai.personal.cr.aliyuncs.com/tuanmiao/yudao-server:latest`

<!-- MANUAL: -->
