# awesome-docker

> 一个精心整理的 Docker Compose 服务集合，帮助开发者快速部署和管理各类容器化应用。

## 项目简介

本项目致力于收集和整理各类实用的 `docker-compose.yaml` 配置文件，覆盖代理/VPN、媒体服务、网络工具、监控系统、开发环境等多个领域。每个配置都经过实际测试，确保开箱即用。

## 快速开始

```bash
# 1. 克隆仓库
git clone https://github.com/harryczqp/awesome-docker.git
cd awesome-docker

# 2. 进入目标服务目录
cd docker-compose/<service-name>

# 3. 根据需求修改配置（端口、卷路径等）
vim docker-compose.yaml

# 4. 启动服务
docker compose up -d
```

## 服务目录

### 代理 / VPN

| 服务 | 说明 | 镜像 |
|------|------|------|
| [3x-ui](./docker-compose/3x-ui) | Xray/VLESS 代理面板 | `ghcr.io/mhsanaei/3x-ui` |
| [sing-box](./docker-compose/sing-box) | 通用代理平台 | `gzxhwq/sing-box` |
| [s-ui](./docker-compose/s-ui) | Sing-box 代理面板 | `alireza7/s-ui` |
| [cloudflared](./docker-compose/cloudflared) | Cloudflare 隧道 | `cloudflare/cloudflared` |
| [wg-easy](./docker-compose/wg-easy) | WireGuard VPN Web 管理 | `wg-easy/wg-easy` |
| [zerotier](./docker-compose/zerotier) | 虚拟 SDN 网络 | `zerotier/zerotier` |
| [easytier](./docker-compose/easytier) | P2P VPN 组网 | `easytier/easytier` |
| [cliproxyapi](./docker-compose/cliproxyapi) | CLI 代理 API | `eceasy/cli-proxy-api` |
| [frp/client](./docker-compose/frp/client) | FRP 内网穿透客户端 | `snowdreamtech/frpc` |
| [frp/server](./docker-compose/frp/server) | FRP 内网穿透服务端 | `snowdreamtech/frps` |

### 网络 / DNS / 网关

| 服务 | 说明 | 镜像 |
|------|------|------|
| [adguard](./docker-compose/adguard) | DNS 广告拦截 | `adguard/adguardhome` |
| [ddnsgo](./docker-compose/ddnsgo) | 动态域名解析 | `jeessy/ddns-go` |
| [lucky](./docker-compose/lucky) | 反向代理 + DDNS | `gdy666/lucky` |
| [traefik](./docker-compose/traefik) | 云原生边缘路由 | `traefik` |
| [npm](./docker-compose/npm) | Nginx Proxy Manager | `jc21/nginx-proxy-manager` |
| [renewx](./docker-compose/renewx) | 证书续期管理 | `harryczqp/renewx` |

### 媒体 / 文件管理

| 服务 | 说明 | 镜像 |
|------|------|------|
| [alist](./docker-compose/alist) | 多网盘聚合管理 | `xhofe/alist` |
| [allinone](./docker-compose/allinone) | IPTV 聚合源 | `youshandefeiyang/allinone` |
| [moontv](./docker-compose/moontv) | MoonTV 流媒体平台 | `ghcr.io/moontechlab/lunatv` |
| [moontvplus](./docker-compose/moontvplus) | MoonTV Plus 增强版 | `ghcr.io/mtvpls/moontvplus` |
| [tvbox](./docker-compose/tvbox) | TVBox 媒体聚合 | `haroldli/xiaoya-tvbox` |
| [xiaoya-tvbox](./docker-compose/xiaoya-tvbox) | 小雅 TVBox + AList | `haroldli/xiaoya-tvbox` |
| [zfile](./docker-compose/zfile) | 在线文件管理 (配置待完善) | - |

### 监控 / 运维

| 服务 | 说明 | 镜像 |
|------|------|------|
| [grafana-prometheus](./docker-compose/grafana-prometheus) | 监控告警栈 | `prom/prometheus` + `grafana/grafana` |
| [cAdvisor](./docker-compose/cAdvisor) | 容器资源监控 | `gcr.io/cadvisor/cadvisor` |
| [sun-panel](./docker-compose/sun-panel) | 服务器管理面板 | `hslr/sun-panel` |

### 开发 / 效率

| 服务 | 说明 | 镜像 |
|------|------|------|
| [code-server](./docker-compose/code-server) | 浏览器版 VS Code | `codercom/code-server` |
| [n8n](./docker-compose/n8n) | 工作流自动化 | `n8nio/n8n` |
| [next-chat](./docker-compose/next-chat) | AI 聊天客户端 | `yidadaa/chatgpt-next-web` |
| [opencode](./docker-compose/opencode) | 代码服务 | `ghcr.io/anomalyco/opencode` |
| [message-pusher](./docker-compose/message-pusher) | 消息推送服务 | `justsong/message-pusher` |
| [aiclient2api](./docker-compose/aiclient2api) | AI 客户端转 API | `justlikemaki/aiclient-2-api` |
| [sub2api](./docker-compose/sub2api) | 订阅转换 API | `weishaw/sub2api` |

### 安全 / 密码

| 服务 | 说明 | 镜像 |
|------|------|------|
| [bitwarden](./docker-compose/bitwarden) | 密码管理器 | `bitwarden/server` |
| [endlessh-go](./docker-compose/endlessh-go) | SSH 蜜罐/ tarpit | `shizunge/endlessh-go` |

### 远程桌面

| 服务 | 说明 | 镜像 |
|------|------|------|
| [rustdesk-api](./docker-compose/rustdesk/rustdesk-api) | RustDesk API 服务 | `rustdesk/rustdesk-server` |
| [rustdesk-pro](./docker-compose/rustdesk/rustdesk-pro) | RustDesk Pro 服务端 | `rustdesk/rustdesk-server` |

### 基础服务

| 服务 | 说明 | 镜像 |
|------|------|------|
| [mysql](./docker-compose/base/mysql) | MySQL 5.7 数据库 | `mysql:5.7` |
| [nginx](./docker-compose/base/nginx) | Nginx 1.31 | `nginx:1.31.0-alpine` |
| [openresty](./docker-compose/base/openresty) | OpenResty + Lua/WAF | `openresty/openresty` |
| [postgres](./docker-compose/base/postgres) | PostgreSQL | `postgres:18-alpine` |
| [redis](./docker-compose/base/redis) | Redis 缓存 | `redis:8-alpine` |
| [tuanmiao](./docker-compose/base/tuanmiao) | 团猫/芋道服务端 | - |

### 其他工具

| 服务 | 说明 | 镜像 |
|------|------|------|
| [antigravity-manager](./docker-compose/antigravity-manager) | 代理管理面板 | `lbjlaq/antigravity-manager` |
| [miair](./docker-compose/miair) | 小米空气净化器联动 | `harryczqp/miair` |
| [speedtest](./docker-compose/speedtest) | 网速测速服务 | `librespeed/speedtest` |
| [speedtest-2](./docker-compose/speedtest-2) | 网络诊断工具 | `wikihostinc/looking-glass-server` |
| [wecomchan](./docker-compose/wecomchan) | 企业微信消息通道 | `aozakiaoko/go-wecomchan` |
| [docker-volume-backup](./docker-compose/docker-volume-backup) | Docker 卷备份 | `offen/docker-volume-backup` |

## 工具脚本 (00Tools)

| 工具 | 说明 |
|------|------|
| [auto-reboot-router](./00Tools/auto-reboot-router) | OpenWrt 智能重启脚本（网络故障自动重启） |
| [docker-volume-backup](./00Tools/docker-volume-backup) | Docker 卷备份、恢复、清理 Python 工具 |
| [git-manager](./00Tools/git-manager) | 批量扫描/恢复 Git 仓库远程地址 |
| [rclone-installer](./00Tools/rclone-installer) | rclone 一键安装与 systemd 挂载管理 |

## 系统管理脚本 (99Other)

| 脚本 | 说明 |
|------|------|
| `fail2ban.sh` | Fail2Ban 防护管理 |
| `set_firewall.sh` | UFW 防火墙配置 |
| `set_network.sh` | 网络配置（Netplan/NetworkManager/传统方式） |
| `set_sshd.sh` | SSH 加固与用户管理 |
| `manage_vpn_nat.sh` | VPN NAT 转发与 systemd 服务管理 |
| `set_timezone.sh` | 时区设置 |

## 使用说明

### 通用配置模式

大多数服务遵循以下配置约定：

- `network_mode: host` — 使用宿主机网络（避免端口映射冲突）
- `restart: unless-stopped` — 自动重启策略
- `json-file` 日志驱动 + 大小限制
- 配置文件挂载到 `/etc/configs/<service>/`

### 常用命令

```bash
# 查看所有运行中的容器
docker ps

# 查看服务日志
docker compose logs -f

# 重启单个服务
docker compose restart <service-name>

# 停止并删除服务
docker compose down

# 验证 compose 文件语法
docker compose config
```

## 贡献指南

1. Fork 本仓库
2. 在 `docker-compose/` 下创建新服务目录
3. 提供 `docker-compose.yaml` 及必要的 `.env` / `README`
4. 确保 `docker compose config` 验证通过
5. 提交 Pull Request

## 许可证

[MIT License](./LICENSE)

---

*本项目持续更新中，欢迎 Star 和 Issue 反馈。*
