<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# docker-compose

## Purpose
Central directory containing all Docker Compose infrastructure definitions for the awesome-docker project. Each subdirectory packages a self-contained service or service group that can be deployed independently via Docker Compose. Services range from base infrastructure (databases, reverse proxies) to applications (FRP, RustDesk, NPM, etc.).

## Key Files
| File | Description |
|------|-------------|
| `*/docker-compose.yaml` or `*/docker-compose.yml` | Service definitions for each subdirectory |

## Subdirectories
| Directory | Purpose |
|-----------|---------|
| `3x-ui/` | Xray/VLESS proxy panel (see `3x-ui/AGENTS.md`) |
| `adguard/` | AdGuard Home DNS ad-blocker (see `adguard/AGENTS.md`) |
| `aiclient2api/` | AI client to API bridge (see `aiclient2api/AGENTS.md`) |
| `alist/` | Alist file list program (see `alist/AGENTS.md`) |
| `allinone/` | All-in-one media service (see `allinone/AGENTS.md`) |
| `antigravity-manager/` | AntiGravity manager (see `antigravity-manager/AGENTS.md`) |
| `base/` | Base infrastructure services — MySQL, Nginx, OpenResty, PostgreSQL, Redis, Tuanmiao (see `base/AGENTS.md`) |
| `bitwarden/` | Bitwarden password manager (see `bitwarden/AGENTS.md`) |
| `cAdvisor/` | Container resource usage monitor (see `cAdvisor/AGENTS.md`) |
| `cliproxyapi/` | CLI proxy API service (see `cliproxyapi/AGENTS.md`) |
| `cloudflared/` | Cloudflare tunnel client (see `cloudflared/AGENTS.md`) |
| `code-server/` | VS Code in the browser (see `code-server/AGENTS.md`) |
| `ddnsgo/` | Dynamic DNS client (see `ddnsgo/AGENTS.md`) |
| `docker-volume-backup/` | Docker volume backup utility (see `docker-volume-backup/AGENTS.md`) |
| `easytier/` | EasyTier VPN mesh (see `easytier/AGENTS.md`) |
| `endlessh-go/` | SSH tarpit service (see `endlessh-go/AGENTS.md`) |
| `frp/` | Fast Reverse Proxy — client and server (see `frp/AGENTS.md`) |
| `grafana-prometheus/` | Monitoring stack (see `grafana-prometheus/AGENTS.md`) |
| `lucky/` | Lucky reverse proxy / DDNS (see `lucky/AGENTS.md`) |
| `message-pusher/` | Message push notification service (see `message-pusher/AGENTS.md`) |
| `miair/` | Mi Air quality monitor (see `miair/AGENTS.md`) |
| `moontv/` | MoonTV streaming service (see `moontv/AGENTS.md`) |
| `moontvplus/` | MoonTV Plus streaming service (see `moontvplus/AGENTS.md`) |
| `n8n/` | n8n workflow automation (see `n8n/AGENTS.md`) |
| `next-chat/` | NextChat AI chat interface (see `next-chat/AGENTS.md`) |
| `npm/` | Nginx Proxy Manager (see `npm/AGENTS.md`) |
| `opencode/` | OpenCode service (see `opencode/AGENTS.md`) |
| `renewx/` | RenewX certificate renewal (see `renewx/AGENTS.md`) |
| `rustdesk/` | RustDesk remote desktop server (see `rustdesk/AGENTS.md`) |
| `sing-box/` | Sing-box proxy tool (see `sing-box/AGENTS.md`) |
| `speedtest/` | Speedtest service (see `speedtest/AGENTS.md`) |
| `speedtest-2/` | Alternative speedtest service (see `speedtest-2/AGENTS.md`) |
| `sub2api/` | Subscription to API converter (see `sub2api/AGENTS.md`) |
| `s-ui/` | S-UI proxy panel (see `s-ui/AGENTS.md`) |
| `sun-panel/` | SunPanel dashboard (see `sun-panel/AGENTS.md`) |
| `traefik/` | Traefik reverse proxy (see `traefik/AGENTS.md`) |
| `tvbox/` | TVBox media service (see `tvbox/AGENTS.md`) |
| `wecomchan/` | WeCom channel notifier (see `wecomchan/AGENTS.md`) |
| `wg-easy/` | WireGuard Easy VPN (see `wg-easy/AGENTS.md`) |
| `xiaoya-tvbox/` | Xiaoya TVBox service (see `xiaoya-tvbox/AGENTS.md`) |
| `zerotier/` | ZeroTier VPN mesh (see `zerotier/AGENTS.md`) |
| `zfile/` | ZFile file manager (see `zfile/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- Each subdirectory is self-contained. Navigate to the target directory before running `docker compose` commands.
- Most services use `network_mode: host` for simplicity; verify port conflicts before starting multiple services.
- Configuration files are typically mounted from `/etc/configs/<service>/` on the host.

### Testing Requirements
- Validate compose files with `docker compose config` before deployment.
- Check for port collisions when running multiple host-network services.

### Common Patterns
- `network_mode: host` is preferred over port mapping.
- `restart: unless-stopped` is used consistently.
- Logging is configured with `json-file` driver and size limits.
- Health checks are defined for stateful services (databases).

## Dependencies

### Internal
- `base/` services are foundational; many application services depend on them.

### External
- Various upstream Docker images (see individual service AGENTS.md files).

<!-- MANUAL: -->
