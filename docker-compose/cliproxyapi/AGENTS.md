<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# cliproxyapi

## Purpose
CLI Proxy API is a multi-service proxy gateway stack consisting of a CLI proxy API server (port 8317) and a usage keeper/monitoring service (port 8318). The main service provides API proxy functionality with configurable authentication, while the usage keeper tracks and manages API usage statistics.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yml` | Docker Compose configuration for cliproxyapi and cpa-usage-keeper |

## For AI Agents

### Working In This Directory
- Modify the docker-compose file to adjust ports, volumes, or environment variables
- Ensure volume paths are absolute or properly relative to the project
- Do not change the service name without updating dependent references
- The main service has CPU (90%) and memory (512MB) resource limits
- Uses a custom bridge network `cpa-network` for inter-service communication
- Mounts external config paths from `/etc/configs/cli-proxy-api/`

### Testing Requirements
- Validate with: `docker compose -f docker-compose.yml config`
- Check that exposed ports do not conflict with other services in this repo
- Verify both services can communicate over the `cpa-network`

### Common Patterns
- Standard Docker Compose single-service or multi-service stack
- Environment variables may be defined inline or in a separate `.env` file

## Dependencies

### External
- `eceasy/cli-proxy-api:latest` — CLI proxy API gateway server
- `ghcr.io/willxup/cpa-usage-keeper:latest` — API usage tracking and monitoring service

<!-- MANUAL: -->
