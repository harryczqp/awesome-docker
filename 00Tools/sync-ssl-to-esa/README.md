# 同步 SSL 证书到本地 Nginx 和阿里云 ESA

`sync_ssl_to_esa.sh` 用于从 HTTP 文件目录拉取 SSL 证书和私钥，保存到 Linux 服务器的 `/etc/configs/nginx/ssl/`，并可选上传到阿里云 ESA 自定义证书。

默认拉取：

- `http://192.168.112.1:16602/ggit.cc.pem`
- `http://192.168.112.1:16602/ggit.cc.key`

默认保存：

- `/etc/configs/nginx/ssl/ggit.cc.pem`
- `/etc/configs/nginx/ssl/ggit.cc.key`

## 1. 准备环境

脚本需要运行在 Linux 下，并建议使用 `root` 或具备写入 `/etc/configs/nginx/ssl/` 权限的用户执行。

安装基础依赖：

```sh
apt update
apt install -y curl openssl
```

如果要上传到阿里云 ESA，还需要安装并配置阿里云 CLI：

```sh
aliyun version
aliyun configure
aliyun configure list
```

确认服务器可以访问证书源地址：

```sh
curl -I -u admin:admin http://192.168.112.1:16602/ggit.cc.pem
curl -I -u admin:admin http://192.168.112.1:16602/ggit.cc.key
```

确认脚本可执行：

```sh
chmod +x /root/sync_ssl.sh
```

## 2. 交互式安装

推荐直接使用交互式安装脚本：

```sh
chmod +x install.sh
./install.sh
```

安装脚本会询问并生成：

- 同步脚本路径，默认 `/root/sync_ssl.sh`
- 配置文件，默认 `/etc/sync-ssl-to-esa.env`
- 证书源地址、用户名、密码、证书文件名、私钥文件名
- 本地保存目录，默认 `/etc/configs/nginx/ssl`
- 是否上传到阿里云 ESA
- 是否配置 cron 定时任务

安装完成后，可直接运行：

```sh
/root/sync_ssl.sh
```

如需修改配置，编辑：

```sh
nano /etc/sync-ssl-to-esa.env
```

## 3. 如何运行

只拉取证书到本地：

```sh
/root/sync_ssl.sh
```

拉取证书并上传到阿里云 ESA：

```sh
ESA_PUSH=1 \
ALIYUN_ESA_SITE_ID=1098350467844576 \
ALIYUN_ESA_CERT_NAME=ggit.cc \
/root/sync_ssl.sh
```

如果源站文件名变了，可以这样配置：

```sh
SOURCE_CERT_FILE=example.com.pem \
SOURCE_KEY_FILE=example.com.key \
/root/sync_ssl.sh
```

如果源站、账号密码或保存目录变了，可以这样配置：

```sh
SOURCE_BASE_URL=http://192.168.112.1:16602/ \
SOURCE_USER=admin \
SOURCE_PASS=admin \
SSL_DIR=/etc/configs/nginx/ssl \
/root/sync_ssl.sh
```

如果拉取后需要重载 Nginx，可以加 `NGINX_RELOAD_CMD`：

```sh
NGINX_RELOAD_CMD="nginx -s reload" /root/sync_ssl.sh
```

常用配置项：

| 变量 | 默认值 | 说明 |
| --- | --- | --- |
| `SOURCE_BASE_URL` | `http://192.168.112.1:16602/` | 证书文件 HTTP 目录 |
| `SOURCE_USER` | `admin` | HTTP Basic Auth 用户名 |
| `SOURCE_PASS` | `admin` | HTTP Basic Auth 密码 |
| `SOURCE_CERT_FILE` | `ggit.cc.pem` | 源站证书文件名 |
| `SOURCE_KEY_FILE` | `ggit.cc.key` | 源站私钥文件名 |
| `SSL_DIR` | `/etc/configs/nginx/ssl` | 本地保存目录 |
| `ESA_PUSH` | `0` | 是否上传 ESA，`1` 为上传 |
| `ALIYUN_ESA_SITE_ID` | 脚本内默认值 | ESA 站点 ID |
| `ALIYUN_ESA_CERT_NAME` | `nginx-时间戳` | 上传到 ESA 的证书名称 |
| `NGINX_RELOAD_CMD` | 空 | 拉取成功后执行的重载命令 |

## 4. 配置 cron 定时执行

建议先新建日志目录：

```sh
mkdir -p /var/log/sync-ssl
```

编辑 root 的 crontab：

```sh
crontab -e
```

每天 `00:01` 和 `08:01` 各执行一次，只同步到本地：

```cron
1 0,8 * * * /root/sync_ssl.sh >> /var/log/sync-ssl/sync_ssl.log 2>&1
```

每天 `00:01` 和 `08:01` 各执行一次，并上传到阿里云 ESA：

```cron
1 0,8 * * * ESA_PUSH=1 ALIYUN_ESA_SITE_ID=1098350467844576 ALIYUN_ESA_CERT_NAME=ggit.cc /root/sync_ssl.sh >> /var/log/sync-ssl/sync_ssl.log 2>&1
```

如果还要在同步后重载 Nginx：

```cron
1 0,8 * * * ESA_PUSH=1 ALIYUN_ESA_SITE_ID=1098350467844576 ALIYUN_ESA_CERT_NAME=ggit.cc NGINX_RELOAD_CMD="nginx -s reload" /root/sync_ssl.sh >> /var/log/sync-ssl/sync_ssl.log 2>&1
```

查看最近执行日志：

```sh
tail -n 100 /var/log/sync-ssl/sync_ssl.log
```

## 注意事项

- cron 环境变量很少，建议在 cron 里写完整脚本路径，比如 `/root/sync_ssl.sh`。
- 如果执行 `install.sh` 时提示 `crontab: not found`，请先安装 cron，例如 Debian/Ubuntu 使用 `apt install -y cron`，并确认服务已启动；安装脚本也会尝试降级写入 `/etc/cron.d/sync-ssl-to-esa` 或 `/etc/crontabs/root`。
- 如果 `aliyun` 在 cron 里找不到，可以先执行 `which aliyun`，然后把 cron 里的 `PATH` 补全，或在脚本中使用 `aliyun` 的绝对路径。
- 上传 ESA 前，脚本会先校验证书和私钥是否匹配；不匹配会直接停止。
- 私钥文件会保存为 `600` 权限，证书目录会尽量设置为 `700` 权限。
