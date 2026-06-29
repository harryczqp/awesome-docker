# awesome-docker

> A curated collection of Docker Compose configurations for quickly deploying and managing containerized self-hosted applications.

[🇨🇳 中文](README.zh.md) | [🇯🇵 日本語](README.ja.md) | [🇬🇧 English](readme.md)

## Overview

This project collects and organizes practical `docker-compose.yaml` configurations covering proxies/VPNs, media services, network tools, monitoring systems, development environments, and more. Each configuration is tested and optimized for production-ready deployment.

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/harryczqp/awesome-docker.git
cd awesome-docker

# 2. Navigate to the target service directory
cd docker-compose/<service-name>

# 3. Modify configuration as needed (ports, volume paths, etc.)
vim docker-compose.yaml

# 4. Start the service
docker compose up -d
```

## Service Catalog

### Proxy / VPN

| Service | Description | Image |
|---------|-------------|-------|
| [3x-ui](./docker-compose/3x-ui) | Xray/VLESS proxy panel | `ghcr.io/mhsanaei/3x-ui` |
| [sing-box](./docker-compose/sing-box) | Universal proxy platform | `gzxhwq/sing-box` |
| [s-ui](./docker-compose/s-ui) | Sing-box proxy panel | `alireza7/s-ui` |
| [cloudflared](./docker-compose/cloudflared) | Cloudflare tunnel | `cloudflare/cloudflared` |
| [wg-easy](./docker-compose/wg-easy) | WireGuard VPN web UI | `wg-easy/wg-easy` |
| [zerotier](./docker-compose/zerotier) | Virtual SDN network | `zerotier/zerotier` |
| [easytier](./docker-compose/easytier) | P2P VPN mesh | `easytier/easytier` |
| [cliproxyapi](./docker-compose/cliproxyapi) | CLI proxy API | `eceasy/cli-proxy-api` |
| [frp/client](./docker-compose/frp/client) | FRP intranet penetration client | `snowdreamtech/frpc` |
| [frp/server](./docker-compose/frp/server) | FRP intranet penetration server | `snowdreamtech/frps` |

### Network / DNS / Gateway

| Service | Description | Image |
|---------|-------------|-------|
| [adguard](./docker-compose/adguard) | DNS ad blocker | `adguard/adguardhome` |
| [ddnsgo](./docker-compose/ddnsgo) | Dynamic DNS client | `jeessy/ddns-go` |
| [lucky](./docker-compose/lucky) | Reverse proxy + DDNS | `gdy666/lucky` |
| [traefik](./docker-compose/traefik) | Cloud-native edge router | `traefik` |
| [npm](./docker-compose/npm) | Nginx Proxy Manager | `jc21/nginx-proxy-manager` |
| [renewx](./docker-compose/renewx) | Certificate renewal manager | `harryczqp/renewx` |

### Media / File Management

| Service | Description | Image |
|---------|-------------|-------|
| [alist](./docker-compose/alist) | Multi-storage file manager | `xhofe/alist` |
| [allinone](./docker-compose/allinone) | IPTV stream aggregator | `youshandefeiyang/allinone` |
| [moontv](./docker-compose/moontv) | MoonTV streaming platform | `ghcr.io/moontechlab/lunatv` |
| [moontvplus](./docker-compose/moontvplus) | MoonTV Plus enhanced | `ghcr.io/mtvpls/moontvplus` |
| [tvbox](./docker-compose/tvbox) | TVBox media aggregator | `haroldli/xiaoya-tvbox` |
| [xiaoya-tvbox](./docker-compose/xiaoya-tvbox) | Xiaoya TVBox + AList | `haroldli/xiaoya-tvbox` |
| [zfile](./docker-compose/zfile) | Online file manager (config pending) | - |

### Monitoring / Operations

| Service | Description | Image |
|---------|-------------|-------|
| [grafana-prometheus](./docker-compose/grafana-prometheus) | Monitoring & alerting stack | `prom/prometheus` + `grafana/grafana` |
| [cAdvisor](./docker-compose/cAdvisor) | Container resource monitor | `gcr.io/cadvisor/cadvisor` |
| [sun-panel](./docker-compose/sun-panel) | Server management dashboard | `hslr/sun-panel` |

### Development / Productivity

| Service | Description | Image |
|---------|-------------|-------|
| [code-server](./docker-compose/code-server) | Browser-based VS Code | `codercom/code-server` |
| [n8n](./docker-compose/n8n) | Workflow automation | `n8nio/n8n` |
| [next-chat](./docker-compose/next-chat) | AI chat client | `yidadaa/chatgpt-next-web` |
| [opencode](./docker-compose/opencode) | Code service | `ghcr.io/anomalyco/opencode` |
| [message-pusher](./docker-compose/message-pusher) | Message push service | `justsong/message-pusher` |
| [aiclient2api](./docker-compose/aiclient2api) | AI client to API gateway | `justlikemaki/aiclient-2-api` |
| [sub2api](./docker-compose/sub2api) | Subscription conversion API | `weishaw/sub2api` |

### Security / Password

| Service | Description | Image |
|---------|-------------|-------|
| [bitwarden](./docker-compose/bitwarden) | Password manager | `bitwarden/server` |
| [endlessh-go](./docker-compose/endlessh-go) | SSH honeypot / tarpit | `shizunge/endlessh-go` |

### Remote Desktop

| Service | Description | Image |
|---------|-------------|-------|
| [rustdesk-api](./docker-compose/rustdesk/rustdesk-api) | RustDesk API server | `rustdesk/rustdesk-server` |
| [rustdesk-pro](./docker-compose/rustdesk/rustdesk-pro) | RustDesk Pro server | `rustdesk/rustdesk-server` |

### Base Infrastructure

| Service | Description | Image |
|---------|-------------|-------|
| [mysql](./docker-compose/base/mysql) | MySQL 5.7 database | `mysql:5.7` |
| [nginx](./docker-compose/base/nginx) | Nginx 1.31 | `nginx:1.31.0-alpine` |
| [openresty](./docker-compose/base/openresty) | OpenResty + Lua/WAF | `openresty/openresty` |
| [postgres](./docker-compose/base/postgres) | PostgreSQL | `postgres:18-alpine` |
| [redis](./docker-compose/base/redis) | Redis cache | `redis:8-alpine` |
| [tuanmiao](./docker-compose/base/tuanmiao) | Tuanmiao/Yudao server | - |

### Other Tools

| Service | Description | Image |
|---------|-------------|-------|
| [antigravity-manager](./docker-compose/antigravity-manager) | Proxy management panel | `lbjlaq/antigravity-manager` |
| [miair](./docker-compose/miair) | Xiaomi air purifier automation | `harryczqp/miair` |
| [speedtest](./docker-compose/speedtest) | Speed test service | `librespeed/speedtest` |
| [speedtest-2](./docker-compose/speedtest-2) | Network diagnostics tool | `wikihostinc/looking-glass-server` |
| [wecomchan](./docker-compose/wecomchan) | WeCom message channel | `aozakiaoko/go-wecomchan` |
| [docker-volume-backup](./docker-compose/docker-volume-backup) | Docker volume backup | `offen/docker-volume-backup` |

## Tool Scripts (00Tools)

| Tool | Description |
|------|-------------|
| [auto-reboot-router](./00Tools/auto-reboot-router) | OpenWrt smart reboot (auto-retry on network failure) |
| [docker-volume-backup](./00Tools/docker-volume-backup) | Docker volume backup, restore, and cleanup Python tool |
| [git-manager](./00Tools/git-manager) | Batch scan/restore Git repository remotes |
| [rclone-installer](./00Tools/rclone-installer) | One-click rclone install with systemd mount management |

## System Administration Scripts (99Other)

| Script | Description |
|--------|-------------|
| `fail2ban.sh` | Fail2Ban protection management |
| `set_firewall.sh` | UFW firewall configuration |
| `set_network.sh` | Network setup (Netplan/NetworkManager/legacy) |
| `set_sshd.sh` | SSH hardening and user management |
| `manage_vpn_nat.sh` | VPN NAT forwarding and systemd service management |
| `set_timezone.sh` | Timezone configuration |

## Usage

### Common Configuration Patterns

Most services follow these conventions:

- `network_mode: host` — Uses host networking (avoids port mapping conflicts)
- `restart: unless-stopped` — Auto-restart policy
- `json-file` log driver with size limits
- Config files mounted to `/etc/configs/<service>/`

### Common Commands

```bash
# List running containers
docker ps

# View service logs
docker compose logs -f

# Restart a single service
docker compose restart <service-name>

# Stop and remove a service
docker compose down

# Validate compose file syntax
docker compose config
```

## Contributing

1. Fork this repository
2. Create a new service directory under `docker-compose/`
3. Provide `docker-compose.yaml` and necessary `.env` / `README`
4. Ensure `docker compose config` validation passes
5. Submit a Pull Request

## License

[MIT License](./LICENSE)

---

*This project is continuously updated. Stars and Issues are welcome.*
