<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# tvbox

## Purpose
TVBox is a media aggregation and streaming platform that collects and organizes video sources. This deployment exposes the management interface on port 4567 and an AList file browser on port 5344, with a named volume for data persistence.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | Docker Compose configuration for tvbox |

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
- `haroldli/xiaoya-tvbox:native` — media aggregation and streaming platform

<!-- MANUAL: -->
