<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# antigravity-manager

## Purpose
Antigravity Manager is a proxy management tool that provides a web-based interface for managing and monitoring proxy connections. It runs in host network mode to directly access localhost proxy ports on the host machine.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | Docker Compose configuration for antigravity-manager |

## For AI Agents

### Working In This Directory
- Modify the docker-compose file to adjust ports, volumes, or environment variables
- Ensure volume paths are absolute or properly relative to the project
- Do not change the service name without updating dependent references
- Uses host network mode; no port mappings needed
- The API_KEY environment variable should be set for security

### Testing Requirements
- Validate with: `docker compose -f docker-compose.yaml config`
- Check that exposed ports do not conflict with other services in this repo

### Common Patterns
- Standard Docker Compose single-service or multi-service stack
- Environment variables may be defined inline or in a separate `.env` file

## Dependencies

### External
- `lbjlaq/antigravity-manager:latest` — Proxy management web interface

<!-- MANUAL: -->
