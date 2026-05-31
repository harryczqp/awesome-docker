<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# allinone

## Purpose
AllInOne is a live TV streaming aggregation service that collects and serves IPTV/live stream sources. It includes two services: the main allinone aggregator (port 35455) and an allinone_format formatter service (port 35456) that processes and formats stream data for consumption.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | Docker Compose configuration for allinone and allinone_format services |

## For AI Agents

### Working In This Directory
- Modify the docker-compose file to adjust ports, volumes, or environment variables
- Ensure volume paths are absolute or properly relative to the project
- Do not change the service name without updating dependent references
- The allinone service uses privileged mode and host network; the formatter uses bridge mode

### Testing Requirements
- Validate with: `docker compose -f docker-compose.yaml config`
- Check that exposed ports do not conflict with other services in this repo

### Common Patterns
- Standard Docker Compose single-service or multi-service stack
- Environment variables may be defined inline or in a separate `.env` file

## Dependencies

### External
- `youshandefeiyang/allinone` — Live TV stream aggregation service
- `yuexuangu/allinone_format:latest` — Stream data formatting service

<!-- MANUAL: -->
