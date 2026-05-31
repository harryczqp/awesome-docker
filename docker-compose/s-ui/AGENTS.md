<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# s-ui

## Purpose
S-UI is a web-based proxy panel built on the Sing-box core. This deployment runs in host network mode with NET_ADMIN/NET_RAW capabilities and TUN device access, providing a management interface for proxy rules and subscriptions.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | Docker Compose configuration for s-ui |

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
- `alireza7/s-ui` — web-based proxy management panel (Sing-box based)

<!-- MANUAL: -->
