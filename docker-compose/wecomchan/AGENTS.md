<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# wecomchan

## Purpose
WeComChan is a WeCom (WeChat Work) message forwarding gateway. This deployment runs a Go-based API service with a Redis backend for message queueing, exposing the gateway on port 8433.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | Docker Compose configuration for wecomchan |

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
- `docker.io/aozakiaoko/go-wecomchan:latest` — WeCom message forwarding API gateway
- `docker.io/bitnami/redis:6.2` — in-memory data store for message queueing

<!-- MANUAL: -->
