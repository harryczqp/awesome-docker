<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# cloudflared

## Purpose
Cloudflared is Cloudflare's tunnel client that creates secure outbound-only connections between your infrastructure and Cloudflare's edge network. It enables exposing local services to the internet without opening inbound firewall ports, using a tunnel token for authentication.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yml` | Docker Compose configuration for cloudflared tunnel |

## For AI Agents

### Working In This Directory
- Modify the docker-compose file to adjust ports, volumes, or environment variables
- Ensure volume paths are absolute or properly relative to the project
- Do not change the service name without updating dependent references
- Requires a `TUNNEL_TOKEN` environment variable for tunnel authentication
- Runs in host network mode for direct network access

### Testing Requirements
- Validate with: `docker compose -f docker-compose.yml config`
- Check that exposed ports do not conflict with other services in this repo
- Ensure `TUNNEL_TOKEN` is set in environment or `.env` file

### Common Patterns
- Standard Docker Compose single-service or multi-service stack
- Environment variables may be defined inline or in a separate `.env` file

## Dependencies

### External
- `cloudflare/cloudflared:latest` — Cloudflare tunnel client for secure outbound connections

<!-- MANUAL: -->
