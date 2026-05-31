<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# server

## Purpose
FRP server (frps) that accepts incoming tunnel connections from FRP clients and routes public traffic to internal services. Configured via a host-mounted TOML file and runs with host networking.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | FRP server service definition |

## Subdirectories
None.

## For AI Agents

### Working In This Directory
- Requires `/etc/configs/frp/frps.toml` on the host before starting.
- Uses `network_mode: host`; ensure required ports are open in the host firewall.
- Typically deployed on a host with a public IP.

### Testing Requirements
- Verify server is listening: `docker compose logs -f frps`.
- Test client connection from a remote host.

### Common Patterns
- Config file mounted from host.
- Minimal logging (1m max size).
- `createdBy: "Apps"` label for inventory tracking.

## Dependencies

### Internal
- `frp/client` — FRP clients connect to this server.

### External
- `ghcr.io/fatedier/frps:v0.64.0`

<!-- MANUAL: -->
