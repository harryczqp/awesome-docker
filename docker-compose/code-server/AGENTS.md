<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# code-server

## Purpose
Code-server is VS Code running on a remote server, accessible through the browser. It provides a full-featured development environment with extensions, terminal access, and file editing capabilities, exposed on port 1080 and mapping to the container's port 8080.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | Docker Compose configuration for code-server |

## For AI Agents

### Working In This Directory
- Modify the docker-compose file to adjust ports, volumes, or environment variables
- Ensure volume paths are absolute or properly relative to the project
- Do not change the service name without updating dependent references
- The default password is set to "123456" — change this in production
- Mounts `~/repos` into the container for development workspace access

### Testing Requirements
- Validate with: `docker compose -f docker-compose.yaml config`
- Check that exposed ports do not conflict with other services in this repo

### Common Patterns
- Standard Docker Compose single-service or multi-service stack
- Environment variables may be defined inline or in a separate `.env` file

## Dependencies

### External
- `codercom/code-server` — Browser-based VS Code development environment

<!-- MANUAL: -->
