<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# sing-box

## Purpose
sing-box is a universal proxy platform supporting multiple protocols (VMess, VLESS, Trojan, Shadowsocks, etc.). This deployment runs in host network mode with NET_ADMIN capability and TUN device access for transparent proxy functionality.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | Docker Compose configuration for sing-box |

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
- `gzxhwq/sing-box:1.12.0-rc.3` — universal proxy platform with multi-protocol support

<!-- MANUAL: -->
