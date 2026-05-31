<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# cAdvisor

## Purpose
cAdvisor (Container Advisor) is a container monitoring tool that provides resource usage and performance characteristics of running containers. It collects, aggregates, processes, and exports information about running containers, exposing metrics on port 9101 for Prometheus scraping.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | Docker Compose configuration for cAdvisor |

## For AI Agents

### Working In This Directory
- Modify the docker-compose file to adjust ports, volumes, or environment variables
- Ensure volume paths are absolute or properly relative to the project
- Do not change the service name without updating dependent references
- Runs in privileged mode with extensive host volume mounts for container introspection
- The port is set via command argument `--port=9101`

### Testing Requirements
- Validate with: `docker compose -f docker-compose.yaml config`
- Check that exposed ports do not conflict with other services in this repo
- On newer Ubuntu systems (22.04+), cgroup mapping may need to be disabled

### Common Patterns
- Standard Docker Compose single-service or multi-service stack
- Environment variables may be defined inline or in a separate `.env` file

## Dependencies

### External
- `m.daocloud.io/gcr.io/cadvisor/cadvisor:latest` — Container resource usage and performance analyzer

<!-- MANUAL: -->
