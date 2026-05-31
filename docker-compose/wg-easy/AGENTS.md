<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# wg-easy

## Purpose
WG-Easy is a web-based management interface for WireGuard VPN. This deployment exposes the WireGuard UDP port (21820) and the web admin panel (51821), with NET_ADMIN and SYS_MODULE capabilities for kernel-level networking.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | Docker Compose configuration for wg-easy |

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
- `ghcr.nju.edu.cn/wg-easy/wg-easy:latest` — web-based WireGuard VPN management UI

<!-- MANUAL: -->
