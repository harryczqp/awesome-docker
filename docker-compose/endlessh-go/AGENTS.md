<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# endlessh-go

## Purpose
Endlessh-go is an SSH tarpit written in Go that traps SSH clients by slowly sending an endless banner. It acts as a honeypot, wasting attackers' time and resources. It also exposes Prometheus metrics on port 9102 for monitoring tarpit activity, with GeoIP support via ip-api.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | Docker Compose configuration for endlessh-go |

## For AI Agents

### Working In This Directory
- Modify the docker-compose file to adjust ports, volumes, or environment variables
- Ensure volume paths are absolute or properly relative to the project
- Do not change the service name without updating dependent references
- Port 22 on the host is mapped to port 2222 in the container (the tarpit SSH port)
- Port 9102 exposes Prometheus metrics from port 2112 in the container
- The `-geoip_supplier ip-api` flag enables GeoIP tracking of connections

### Testing Requirements
- Validate with: `docker compose -f docker-compose.yaml config`
- Check that exposed ports do not conflict with other services in this repo
- Ensure port 22 is not already in use by the host SSH service

### Common Patterns
- Standard Docker Compose single-service or multi-service stack
- Environment variables may be defined inline or in a separate `.env` file

## Dependencies

### External
- `shizunge/endlessh-go` — SSH tarpit/honeypot with Prometheus metrics and GeoIP support

<!-- MANUAL: -->
