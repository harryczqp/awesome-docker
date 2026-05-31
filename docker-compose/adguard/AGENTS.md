<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# adguard

## Purpose
AdGuard Home is a network-wide ad and tracker blocking DNS server. It acts as a DNS sinkhole, filtering unwanted content at the DNS level for all devices on the network, with a web-based management interface accessible on port 3001.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | Docker Compose configuration for AdGuard Home |

## For AI Agents

### Working In This Directory
- Modify the docker-compose file to adjust ports, volumes, or environment variables
- Ensure volume paths are absolute or properly relative to the project
- Do not change the service name without updating dependent references

### Testing Requirements
- Validate with: `docker compose -f docker-compose.yaml config`
- Check that exposed ports do not conflict with other services in this repo
- Note: Port 53 is used for DNS (TCP/UDP), port 3001 maps to the web UI

### Common Patterns
- Standard Docker Compose single-service or multi-service stack
- Environment variables may be defined inline or in a separate `.env` file

## Dependencies

### External
- `adguard/adguardhome:${IMAGE_TAG:-latest}` — Network-wide ad and tracker blocking DNS server

<!-- MANUAL: -->
