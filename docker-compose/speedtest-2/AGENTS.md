<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# speedtest-2

## Purpose
Speedtest-2 is a network diagnostics server (WikiHost Looking Glass) providing ping, traceroute, iperf3, and other network testing utilities. This deployment exposes web and iperf3 ports with Traefik labels for reverse proxy integration.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | Docker Compose configuration for speedtest-2 |

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
- `wikihostinc/looking-glass-server:latest` — network diagnostics and looking glass server

<!-- MANUAL: -->
