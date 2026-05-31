<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# traefik

## Purpose
Traefik is a modern reverse proxy and load balancer with automatic service discovery. This deployment runs Traefik v3.6 with Docker provider enabled, exposing HTTP (port 80) and dashboard (port 8080), with SSL certificate storage and basic auth for the dashboard.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | Docker Compose configuration for traefik |
| `acme.json` | SSL certificate storage (ACME) |
| `readme.md` | Traefik label examples for HTTP/HTTPS routing |

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
- `traefik:v3.6` — cloud-native reverse proxy and load balancer

<!-- MANUAL: -->
