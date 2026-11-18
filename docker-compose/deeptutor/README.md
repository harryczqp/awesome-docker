# DeepTutor

项目：https://github.com/HKUDS/DeepTutor

使用官方镜像 `ghcr.io/hkuds/deeptutor:latest`，包含前端和后端。默认单个后端 worker，使用内存协调器，不需要 Redis。后续增加 worker 时，需按官方说明添加 Redis 并修改 `system.json` 的 `turn_coordination` 设置。

## 首次配置

环境变量保存在仓库外的 `/etc/configs/deeptutor/.env`；应用数据保存在命名卷 `data`（默认实际名称为 `deeptutor_data`），挂载到容器的 `/app/data`：

```bash
mkdir -p /etc/configs/deeptutor
chmod 700 /etc/configs/deeptutor
```

创建 `/etc/configs/deeptutor/.env`：

```dotenv
TZ=Asia/Shanghai
PUID=1000
PGID=1000
DEEPTUTOR_WORKSPACE_ROOT=/app/data/user/workspace
DEEPTUTOR_WORKSPACE_ALLOWED_ROOTS=/app/data/user/workspace
# 可选扩展，按需启用，会在启动时安装：
# DEEPTUTOR_EXTRAS=math-animator,partners
# DEEPTUTOR_APT_PACKAGES=ffmpeg
```

```bash
chmod 600 /etc/configs/deeptutor/.env
```

镜像默认使用 UID/GID `1000:1000` 运行应用，可通过 `.env` 的 `PUID`/`PGID` 调整。启动入口会初始化数据卷并设置应用用户的写入权限。

## 启动

在本目录执行：

```bash
podman compose config >/dev/null
podman compose up -d
podman logs -f deeptutor
```

Docker 环境可将 `podman compose` 换成 `docker compose`，先执行 `docker compose config --quiet` 校验。

访问 `http://宿主机IP:3782`；后端为 `http://宿主机IP:8001`。当前镜像通过前端代理访问容器内的后端，默认无需填写服务器 IP。

首次启动会初始化容器内的 `/app/data/user/settings/`，内容保存在数据卷中。在 Web 设置中配置模型供应商、API Key 和嵌入模型；也可编辑该目录的 `model_catalog.json`。新版镜像从 JSON 加载端口、认证及模型设置，不要把这些设置当作环境变量填入 `.env`。

`system.json` 中的容器端口需与 Compose 映射及健康检查保持一致。认证配置位于同目录的 `auth.json`，开放给其他用户前应完成认证配置。

完整的 `/app/data` 已持久化，包含账号、密钥、知识库及工作区。备份时保存 `deeptutor_data` 数据卷和 `/etc/configs/deeptutor/.env`；不要使用 `compose down -v`，该命令会删除数据卷。2 核、4GB 是初始资源上限，大文档解析或本地模型可能需要提高。
