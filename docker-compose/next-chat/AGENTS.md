<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# next-chat

## Purpose
NextChat (ChatGPT Next Web) is a self-hosted web client for interacting with OpenAI-compatible APIs. This deployment exposes a web UI on port 3044 with MCP (Model Context Protocol) enabled and a custom base URL for API proxying.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yml` | Docker Compose configuration for next-chat |

## For AI Agents

### Working In This Directory
- Modify the docker-compose file to adjust ports, volumes, or environment variables
- Ensure volume paths are absolute or properly relative to the project
- Do not change the service name without updating dependent references

### Testing Requirements
- Validate with: `docker compose -f docker-compose.yml config`
- Check that exposed ports do not conflict with other services in this repo

### Common Patterns
- Standard Docker Compose single-service or multi-service stack
- Environment variables may be defined inline or in a separate `.env` file

## Dependencies

### External
- `m.daocloud.io/docker.io/yidadaa/chatgpt-next-web` — self-hosted ChatGPT web UI with MCP support

<!-- MANUAL: -->
