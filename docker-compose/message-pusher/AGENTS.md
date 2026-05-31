<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# message-pusher

## Purpose
Message Pusher is a unified message push service that supports multiple notification channels. It provides a web API for sending messages through various platforms, making it easy to integrate notifications into applications and services.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | Docker Compose configuration for message-pusher |

## For AI Agents

### Working In This Directory
- Modify the docker-compose file to adjust ports, volumes, or environment variables
- Ensure volume paths are absolute or properly relative to the project
- Do not change the service name without updating dependent references
- The service exposes port 13000 mapped to the container's port 3000
- Logging is configured with a 10MB max size and 3 max files

### Testing Requirements
- Validate with: `docker compose -f docker-compose.yaml config`
- Check that exposed ports do not conflict with other services in this repo

### Common Patterns
- Standard Docker Compose single-service or multi-service stack
- Environment variables may be defined inline or in a separate `.env` file

## Dependencies

### External
- `justsong/message-pusher` — Unified multi-channel message push notification service

<!-- MANUAL: -->
