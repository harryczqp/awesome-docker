<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# frp

## Purpose
Fast Reverse Proxy (FRP) deployment providing both client (frpc) and server (frps) components for exposing internal services behind NAT/firewalls to the public internet. The server listens for incoming tunnels; the client initiates outbound connections to establish them.

## Key Files
| File | Description |
|------|-------------|
| `client/docker-compose.yaml` | FRP client (frpc) service definition |
| `server/docker-compose.yaml` | FRP server (frps) service definition |

## Subdirectories
| Directory | Purpose |
|-----------|---------|
| `client/` | FRP client — tunnels local services to remote FRP server (see `client/AGENTS.md`) |
| `server/` | FRP server — accepts incoming tunnel connections (see `server/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- Server and client are typically deployed on different hosts.
- Both use `network_mode: host` and read TOML configs from `/etc/configs/frp/`.
- Ensure the server host has the required ports (7000, 7500, etc.) open in the firewall.

### Testing Requirements
- Start server first, then client.
- Verify tunnel establishment in frpc/frps logs.

### Common Patterns
- TOML configuration files mounted from host.
- JSON-file logging with 1m max size.
- `command: ["-c", "/etc/frp/frp*.toml"]` for config-driven startup.

## Dependencies

### Internal
- None.

### External
- `ghcr.io/fatedier/frps:v0.64.0` (server)
- `ghcr.io/fatedier/frpc:v0.64.0` (client)

<!-- MANUAL: -->
