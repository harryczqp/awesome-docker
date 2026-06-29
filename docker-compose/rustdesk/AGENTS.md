<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# rustdesk

## Purpose
RustDesk remote desktop infrastructure providing self-hosted relay (hbbr) and signaling (hbbs) servers for secure remote access. Also includes optional API server variants for user/device management.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | Core RustDesk server — hbbs (signaling) and hbbr (relay) services |

## Subdirectories
| Directory | Purpose |
|-----------|---------|
| `rustdesk-api/` | Open-source RustDesk API server for user/device management (see `rustdesk-api/AGENTS.md`) |
| `rustdesk-pro/` | RustDesk API Server Pro with advanced features (see `rustdesk-pro/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- Core services (hbbs + hbbr) use `network_mode: host` and share a named volume `data`.
- hbbs depends on hbbr; start hbbr first.
- Firewall rules may be needed for TCP ports 21115-21119 and UDP 21116.

### Testing Requirements
- Verify both containers are running: `docker compose ps`.
- Test remote desktop connection from a RustDesk client.
- Check logs: `docker compose logs -f hbbs` and `docker compose logs -f hbbr`.

### Common Patterns
- `hbbs` (signaling) depends on `hbbr` (relay).
- Shared volume for server keys and data.
- Host networking for direct port access.

## Dependencies

### Internal
- None.

### External
- `rustdesk/rustdesk-server:latest`

<!-- MANUAL: -->
