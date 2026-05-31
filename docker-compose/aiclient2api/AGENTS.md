<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# aiclient2api

## Purpose
AIClient2API is a unified API gateway that proxies and translates requests between various AI client interfaces and multiple AI service providers (Gemini, Antigravity, iFlow, Codex, Kiro). It exposes multiple port ranges to handle different provider protocols, allowing a single endpoint to route to different AI backends.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | Docker Compose configuration for aiclient2api |

## For AI Agents

### Working In This Directory
- Modify the docker-compose file to adjust ports, volumes, or environment variables
- Ensure volume paths are absolute or properly relative to the project
- Do not change the service name without updating dependent references
- The service exposes ports 3001 (main), 8085-8087 (provider ranges), 1455, and 19876-19880

### Testing Requirements
- Validate with: `docker compose -f docker-compose.yaml config`
- Check that exposed ports do not conflict with other services in this repo
- Verify healthcheck endpoint responds correctly

### Common Patterns
- Standard Docker Compose single-service or multi-service stack
- Environment variables may be defined inline or in a separate `.env` file

## Dependencies

### External
- `justlikemaki/aiclient-2-api:latest` — Unified AI client API gateway supporting multiple AI providers

<!-- MANUAL: -->
