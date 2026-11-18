# Magpie

环境变量保存在仓库外的 `/etc/configs/magpie/.env`，Compose 通过 `env_file` 加载。
首次部署时创建该文件，内容如下：

```dotenv
TZ=Asia/Shanghai
MAGPIE_WEB_KEY=替换为随机密钥
# MAGPIE_PUBLIC_URL=http://宿主机IP:3425
```

使用 `openssl rand -hex 16` 生成 Web 登录密钥，并将 `.env` 权限设为 `600`。
应用数据使用命名卷 `data`（默认实际名称为 `magpie_data`），挂载到 `/config`。
首次创建卷时从镜像初始化目录及权限，无需为宿主机数据目录设置权限。
备份时保存该数据卷和 `/etc/configs/magpie/.env`。

在本目录执行 `docker compose config --quiet` 检查配置，然后执行 `docker compose up -d` 启动。
Podman 环境执行 `podman compose config >/dev/null` 和 `podman compose up -d`。
Web 管理界面通过 `http://宿主机IP:3430` 访问；登录密钥为 `.env` 中的 `MAGPIE_WEB_KEY`，登录链接可从容器日志获取。
