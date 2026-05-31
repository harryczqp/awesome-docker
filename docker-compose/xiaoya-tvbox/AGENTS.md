<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# xiaoya-tvbox

## Purpose
Xiaoya TVBox is a media aggregation platform combining TVBox streaming with AList cloud storage browsing. This deployment exposes the management interface and AList file browser on configurable ports, with a named volume for data storage.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | Docker Compose configuration for xiaoya-tvbox |

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
- `haroldli/xiaoya-tvbox:latest` — media aggregation platform with AList integration

<!-- MANUAL: -->
