<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# awesome-docker

## Purpose
A curated collection of practical `docker-compose.yaml` configurations and utility scripts for quickly deploying and managing containerized self-hosted applications. Covers web services, databases, monitoring tools, VPN/proxy services, media servers, and infrastructure utilities. Each service directory contains a tested and optimized Docker Compose file ready for development, testing, or production use.

## Key Files

| File | Description |
|------|-------------|
| `readme.md` | Project overview, program list, and contribution guidelines |
| `LICENSE` | Project license |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `00Tools/` | Utility scripts for Docker management, networking, and system automation (see `00Tools/AGENTS.md`) |
| `99Other/` | Miscellaneous system administration and network configuration scripts (see `99Other/AGENTS.md`) |
| `99 Other/` | Additional system scripts (see `99 Other/AGENTS.md`) |
| `docker-compose/` | Docker Compose service configurations organized by application (see `docker-compose/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- New services should be added under `docker-compose/{service-name}/` with a `docker-compose.yaml` (or `.yml`) file
- Utility scripts belong in `00Tools/` or `99Other/` depending on scope
- Follow existing naming conventions: lowercase with hyphens for directories
- Prefer `docker-compose.yaml` over `.yml` for consistency with existing services

### Testing Requirements
- Validate Docker Compose files with `docker compose config` before committing
- Ensure volume paths and port mappings do not conflict with existing services
- Check that referenced environment files (`.env`) are documented in the service directory

### Common Patterns
- Each service lives in its own directory under `docker-compose/`
- Most services use a single `docker-compose.yaml` with optional `.env` or README
- Base infrastructure services (MySQL, Nginx, Redis, Postgres) are grouped under `docker-compose/base/`
- VPN/proxy tools often include client/server subdirectories (e.g., `frp/`, `rustdesk/`)

## Dependencies

### External
- Docker Engine & Docker Compose - Container runtime and orchestration
- Various upstream container images as referenced in each `docker-compose.yaml`

<!-- MANUAL: -->
