<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# moontv

## Purpose
MoonTV is a media streaming platform consisting of a core web application and a Kvrocks (Redis-compatible) key-value store for data persistence. The core service provides a web UI for media streaming, while Kvrocks stores application data. Both services run in host network mode.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | Docker Compose configuration for moontv core and kvrocks |

## For AI Agents

### Working In This Directory
- Modify the docker-compose file to adjust ports, volumes, or environment variables
- Ensure volume paths are absolute or properly relative to the project
- Do not change the service name without updating dependent references
- Both services run in host network mode
- The core service depends on kvrocks being available
- Default credentials are USERNAME=admin / PASSWORD=admin — change in production
- Kvrocks data is persisted via the `kvrocks-data` volume

### Testing Requirements
- Validate with: `docker compose -f docker-compose.yaml config`
- Check that exposed ports do not conflict with other services in this repo
- Verify Kvrocks is accessible before the core service starts

### Common Patterns
- Standard Docker Compose single-service or multi-service stack
- Environment variables may be defined inline or in a separate `.env` file

## Dependencies

### External
- `ghcr.io/moontechlab/lunatv:latest` — MoonTV media streaming web application
- `apache/kvrocks` — Redis-compatible key-value store for data persistence

<!-- MANUAL: -->
