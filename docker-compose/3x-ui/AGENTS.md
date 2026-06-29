<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# 3x-ui

## Purpose
3x-ui is a web-based Xray panel that provides a user interface for managing Xray proxy protocols (VMess, VLESS, Trojan, Shadowsocks, etc.). It simplifies the configuration and management of Xray-based proxy services through a web dashboard.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | Docker Compose configuration for 3x-ui |

## For AI Agents

### Working In This Directory
- Modify the docker-compose file to adjust ports, volumes, or environment variables
- Ensure volume paths are absolute or properly relative to the project
- Do not change the service name without updating dependent references

### Testing Requirements
- Validate with: `docker compose -f docker-compose.yaml config`
- Check that exposed ports do not conflict with other services in this repo

### Common Patterns
- Standard Docker Compose single-service or multi-service stack
- Environment variables may be defined inline or in a separate `.env` file

## Dependencies

### External
- `ghcr.io/mhsanaei/3x-ui:latest` — Web-based Xray panel with proxy protocol management UI

<!-- MANUAL: -->
