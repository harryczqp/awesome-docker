<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# client

## Purpose
FRP client (frpc) that establishes outbound tunnels to a remote FRP server, exposing local services behind NAT or firewall to the internet. Reads its configuration from a host-mounted TOML file.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | FRP client service definition |

## Subdirectories
None.

## For AI Agents

### Working In This Directory
- Requires `/etc/configs/frp/frpc.toml` on the host before starting.
- Uses `network_mode: host` for local service access.
- Must point to a running FRP server.

### Testing Requirements
- Verify connection to FRP server in logs: `docker compose logs -f frpc`.
- Confirm tunnels are active on the server dashboard.

### Common Patterns
- Config file mounted read-only from host.
- Minimal logging (1m max size).

## Dependencies

### Internal
- `frp/server` — the target FRP server instance.

### External
- `ghcr.io/fatedier/frpc:v0.64.0`

<!-- MANUAL: -->
