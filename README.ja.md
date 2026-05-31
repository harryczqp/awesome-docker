# awesome-docker

> Docker Compose を使用した様々なコンテナ化アプリケーションの迅速なデプロイと管理を支援する、精心的にカーティングされたサービス集合。

[🇨🇳 中文](README.zh.md) | [🇯🇵 日本語](README.ja.md) | [🇬🇧 English](readme.md)

## プロジェクト概要

本プロジェクトは、プロキシ/VPN、メディアサービス、ネットワークツール、監視システム、開発環境など、多岐にわたる領域をカバーする実用的な `docker-compose.yaml` 構成ファイルを収集・整理することを目指しています。各構成は実際にテストされ、即座に使用できる状態で提供されています。

## クイックスタート

```bash
# 1. リポジトリをクローン
git clone https://github.com/harryczqp/awesome-docker.git
cd awesome-docker

# 2. 対象サービスディレクトリに移動
cd docker-compose/<service-name>

# 3. 必要に応じて構成を変更（ポート、ボリュームパスなど）
vim docker-compose.yaml

# 4. サービスを起動
docker compose up -d
```

## サービス一覧

### プロキシ / VPN

| サービス | 説明 | イメージ |
|------|------|------|
| [3x-ui](./docker-compose/3x-ui) | Xray/VLESS プロキシパネル | `ghcr.io/mhsanaei/3x-ui` |
| [sing-box](./docker-compose/sing-box) | ユニバーサルプロキシプラットフォーム | `gzxhwq/sing-box` |
| [s-ui](./docker-compose/s-ui) | Sing-box プロキシパネル | `alireza7/s-ui` |
| [cloudflared](./docker-compose/cloudflared) | Cloudflare トンネル | `cloudflare/cloudflared` |
| [wg-easy](./docker-compose/wg-easy) | WireGuard VPN Web管理 | `wg-easy/wg-easy` |
| [zerotier](./docker-compose/zerotier) | 仮想SDNネットワーク | `zerotier/zerotier` |
| [easytier](./docker-compose/easytier) | P2P VPNメッシュネットワーク | `easytier/easytier` |
| [cliproxyapi](./docker-compose/cliproxyapi) | CLIプロキシAPI | `eceasy/cli-proxy-api` |
| [frp/client](./docker-compose/frp/client) | FRPインターネット穿透クライアント | `snowdreamtech/frpc` |
| [frp/server](./docker-compose/frp/server) | FRPインターネット穿透サーバー | `snowdreamtech/frps` |

### ネットワーク / DNS / ゲートウェイ

| サービス | 説明 | イメージ |
|------|------|------|
| [adguard](./docker-compose/adguard) | DNS広告ブロッカー | `adguard/adguardhome` |
| [ddnsgo](./docker-compose/ddnsgo) | 動的DNSクライアント | `jeessy/ddns-go` |
| [lucky](./docker-compose/lucky) | リバースプロキシ + DDNS | `gdy666/lucky` |
| [traefik](./docker-compose/traefik) | クラウドネイティブエッジルーター | `traefik` |
| [npm](./docker-compose/npm) | Nginx Proxy Manager | `jc21/nginx-proxy-manager` |
| [renewx](./docker-compose/renewx) | 証明書更新管理 | `harryczqp/renewx` |

### メディア / ファイル管理

| サービス | 説明 | イメージ |
|------|------|------|
| [alist](./docker-compose/alist) | 多ストレージ統合マネージャー | `xhofe/alist` |
| [allinone](./docker-compose/allinone) | IPTV統合ソース | `youshandefeiyang/allinone` |
| [moontv](./docker-compose/moontv) | MoonTVストリーミングプラットフォーム | `ghcr.io/moontechlab/lunatv` |
| [moontvplus](./docker-compose/moontvplus) | MoonTV Plus増強版 | `ghcr.io/mtvpls/moontvplus` |
| [tvbox](./docker-compose/tvbox) | TVBoxメディア統合 | `haroldli/xiaoya-tvbox` |
| [xiaoya-tvbox](./docker-compose/xiaoya-tvbox) | 小雅TVBox + AList | `haroldli/xiaoya-tvbox` |
| [zfile](./docker-compose/zfile) | オンラインファイルマネージャー (構成待ち) | - |

### 監視 / 運用

| サービス | 説明 | イメージ |
|------|------|------|
| [grafana-prometheus](./docker-compose/grafana-prometheus) | 監視・警報スタック | `prom/prometheus` + `grafana/grafana` |
| [cAdvisor](./docker-compose/cAdvisor) | コンテナ資源監視 | `gcr.io/cadvisor/cadvisor` |
| [sun-panel](./docker-compose/sun-panel) | サーバー管理パネル | `hslr/sun-panel` |

### 開発 / 効率化

| サービス | 説明 | イメージ |
|------|------|------|
| [code-server](./docker-compose/code-server) | ブラウザ版VS Code | `codercom/code-server` |
| [n8n](./docker-compose/n8n) | ワークフロー自動化 | `n8nio/n8n` |
| [next-chat](./docker-compose/next-chat) | AIチャットクライアント | `yidadaa/chatgpt-next-web` |
| [opencode](./docker-compose/opencode) | コードサービス | `ghcr.io/anomalyco/opencode` |
| [message-pusher](./docker-compose/message-pusher) | メッセージプッシュサービス | `justsong/message-pusher` |
| [aiclient2api](./docker-compose/aiclient2api) | AIクライアントをAPI化 | `justlikemaki/aiclient-2-api` |
| [sub2api](./docker-compose/sub2api) | サブスクリプション変換API | `weishaw/sub2api` |

### セキュリティ / パスワード

| サービス | 説明 | イメージ |
|------|------|------|
| [bitwarden](./docker-compose/bitwarden) | パスワードマネージャー | `bitwarden/server` |
| [endlessh-go](./docker-compose/endlessh-go) | SSHハニーポット / tarpit | `shizunge/endlessh-go` |

### リモートデスクトップ

| サービス | 説明 | イメージ |
|------|------|------|
| [rustdesk-api](./docker-compose/rustdesk/rustdesk-api) | RustDesk APIサービス | `rustdesk/rustdesk-server` |
| [rustdesk-pro](./docker-compose/rustdesk/rustdesk-pro) | RustDesk Proサーバー | `rustdesk/rustdesk-server` |

### 基盤サービス

| サービス | 説明 | イメージ |
|------|------|------|
| [mysql](./docker-compose/base/mysql) | MySQL 5.7 データベース | `mysql:5.7` |
| [nginx](./docker-compose/base/nginx) | Nginx 1.31 | `nginx:1.31.0-alpine` |
| [openresty](./docker-compose/base/openresty) | OpenResty + Lua/WAF | `openresty/openresty` |
| [postgres](./docker-compose/base/postgres) | PostgreSQL | `postgres:18-alpine` |
| [redis](./docker-compose/base/redis) | Redisキャッシュ | `redis:8-alpine` |
| [tuanmiao](./docker-compose/base/tuanmiao) | 団猫/芋道サーバー | - |

### その他のツール

| サービス | 説明 | イメージ |
|------|------|------|
| [antigravity-manager](./docker-compose/antigravity-manager) | プロキシ管理パネル | `lbjlaq/antigravity-manager` |
| [miair](./docker-compose/miair) | 小米空気清浄器連携 | `harryczqp/miair` |
| [speedtest](./docker-compose/speedtest) | スピードテストサービス | `librespeed/speedtest` |
| [speedtest-2](./docker-compose/speedtest-2) | ネットワーク診断ツール | `wikihostinc/looking-glass-server` |
| [wecomchan](./docker-compose/wecomchan) | 企業微信メッセージ通信 | `aozakiaoko/go-wecomchan` |
| [docker-volume-backup](./docker-compose/docker-volume-backup) | Dockerボリュームバックアップ | `offen/docker-volume-backup` |

## ツールスクリプト (00Tools)

| ツール | 説明 |
|------|------|
| [auto-reboot-router](./00Tools/auto-reboot-router) | OpenWrt智能再起動スクリプト（ネットワーク障害時自動再起動） |
| [docker-volume-backup](./00Tools/docker-volume-backup) | Dockerボリュームのバックアップ・復元・清掏Pythonツール |
| [git-manager](./00Tools/git-manager) | Gitリポジトリの一括スキャン/リモート復元 |
| [rclone-installer](./00Tools/rclone-installer) | rcloneワンクリックインストールとsystemdマウント管理 |

## システム管理スクリプト (99Other)

| スクリプト | 説明 |
|------|------|
| `fail2ban.sh` | Fail2Ban防議管理 |
| `set_firewall.sh` | UFWファイアウォール設定 |
| `set_network.sh` | ネットワーク設定（Netplan/NetworkManager/伝統方式） |
| `set_sshd.sh` | SSH強化とユーザー管理 |
| `manage_vpn_nat.sh` | VPN NAT転送とsystemdサービス管理 |
| `set_timezone.sh` | タイムゾーン設定 |

## 使用説明

### 共通構成パターン

大多数のサービスは以下の構成要約に従います：

- `network_mode: host` — ホストネットワークを使用（ポートマッピングの競合を回避）
- `restart: unless-stopped` — 自動再起動ポリシー
- `json-file` ログドライバー + サイズ制限
- 設定ファイルは `/etc/configs/<service>/` にマウント

### 使用頻度の高いコマンド

```bash
# 実行中のコンテナ一覧
docker ps

# サービスログの確認
docker compose logs -f

# 単一サービスの再起動
docker compose restart <service-name>

# サービスの停止と削除
docker compose down

# composeファイルの構文チェック
docker compose config
```

## 貢献ガイド

1. 本リポジトリをFork
2. `docker-compose/` 下に新しいサービスディレクトリを作成
3. `docker-compose.yaml` と必要な `.env` / `README` を提供
4. `docker compose config` で構文チェックが通ることを確認
5. Pull Requestを提出

## ライセンス

[MIT License](./LICENSE)

---

*本プロジェクトは継続的に更新中です。StarやIssueのフィードバックを歓迎します。*
