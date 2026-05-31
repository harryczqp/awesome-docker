<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# ddnsgo

## Purpose
DDNS-Go is a dynamic DNS client that automatically updates DNS records when your public IP address changes. It supports multiple DNS providers and monitors IP changes at configurable intervals (default 600 seconds), running in host network mode for direct internet access.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | Docker Compose configuration for ddns-go |

## For AI Agents

### Working In This Directory
- Modify the docker-compose file to adjust ports, volumes, or environment variables
- Ensure volume paths are absolute or properly relative to the project
- Do not change the service name without updating dependent references
- Runs in host network mode; the web UI listens on port 9876
- The `-f 600` flag sets the IP check interval to 600 seconds

### Testing Requirements
- Validate with: `docker compose -f docker-compose.yaml config`
- Check that exposed ports do not conflict with other services in this repo

### Common Patterns
- Standard Docker Compose single-service or multi-service stack
- Environment variables may be defined inline or in a separate `.env` file

## Dependencies

### External
- `jeessy/ddns-go:${IMAGE_TAG:-latest}` — Dynamic DNS client with automatic IP update

<!-- MANUAL: -->
