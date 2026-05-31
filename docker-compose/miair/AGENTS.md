<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# miair

## Purpose
MiAir is a custom service for interacting with Xiaomi Air purifiers or similar Mi Home devices. It runs in host network mode for direct LAN device discovery and communication, providing automation and control capabilities for Xiaomi ecosystem devices.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yml` | Docker Compose configuration for miair |

## For AI Agents

### Working In This Directory
- Modify the docker-compose file to adjust ports, volumes, or environment variables
- Ensure volume paths are absolute or properly relative to the project
- Do not change the service name without updating dependent references
- Runs in host network mode for direct LAN device communication
- No ports are explicitly exposed; service communicates over the local network

### Testing Requirements
- Validate with: `docker compose -f docker-compose.yml config`
- Check that exposed ports do not conflict with other services in this repo

### Common Patterns
- Standard Docker Compose single-service or multi-service stack
- Environment variables may be defined inline or in a separate `.env` file

## Dependencies

### External
- `harryczqp/miair:latest` — Xiaomi Air/Mi Home device automation and control service

<!-- MANUAL: -->
