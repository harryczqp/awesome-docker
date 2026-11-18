# PanSou + PanCheck

部署三个服务：

- **PanSou** (`0.0.0.0:8888`)：上游公开 Telegram 频道和插件来源的网盘链接搜索 API。
- **PanCheck** (`127.0.0.1:6080`)：网盘分享链接有效性检测 API 和管理后台。
- **PansouAndPanCheck** (`0.0.0.0:1566`)：唯一推荐给客户端使用的聚合入口；调用 PanSou 搜索，并通过 PanCheck 过滤失效链接。

本 compose **不创建** MySQL 或 Redis：PanCheck 使用宿主机已有的 Base MySQL（3306）与 Redis（6379）。

## 配置

在启动前创建 `/etc/configs/pansou-pancheck/.env`，权限应为 `600`。所需变量：

```dotenv
# PanSou 和聚合代理 API 认证；AUTH_ENABLED=true 时必须提供
AUTH_USERS=admin:replace-with-a-strong-password
AUTH_JWT_SECRET=replace-with-a-long-random-secret

# 聚合代理访问已启用认证的 PanSou；密码必须与 AUTH_USERS 中 admin 的密码一致
PANSOU_AUTH_PASSWORD=replace-with-the-same-pansou-admin-password

# PanCheck 使用已有 Base MySQL / Redis
DATABASE_PASSWORD=replace-with-the-existing-mysql-root-password
REDIS_PASSWORD=
ADMIN_PASSWORD=replace-with-a-strong-admin-password
```

说明：

- `AUTH_USERS` 和 `AUTH_JWT_SECRET` 同时被 compose 的两个服务读取；PanCheck 会忽略其不认识的变量。
- `DATABASE_PASSWORD` 是已有 Base MySQL 的 root 密码；部署脚本会创建独立数据库 `pancheck`。
- Base Redis 当前如未启用认证，`REDIS_PASSWORD` 保持为空。
- PanCheck 仅监听本机 `127.0.0.1:6080`，不直接暴露外网；PanSou 对外监听 `8888`，并启用了 JWT 认证。

## 启动与验证

```bash
cd /root/repos/awesome-docker/docker-compose/pansou-pancheck
podman compose up -d
podman compose ps
podman logs -f pansou
podman logs -f pancheck
```

```bash
curl http://127.0.0.1:8888/api/health
curl http://127.0.0.1:6080/api/v1/health
```

PanSou 搜索 API 需要先通过 `POST /api/auth/login` 获取 JWT，再调用 `/api/search`。

## 安全与合规

仅搜索公开来源，不缓存或分发资源内容。请只检索你有权访问和使用的内容；不要把服务以无认证方式暴露到公网。PanCheck 检测并发默认设为 3，以降低触发网盘平台限流/风控的风险。

> 当前 compose 只部署 PanSou 和 PanCheck；未部署 `PansouAndPanCheck` 代理层。PanCheck 可独立用于批量/定时检测，或由后续自有前端/服务按需调用。
