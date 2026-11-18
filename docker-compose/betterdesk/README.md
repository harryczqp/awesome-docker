# BetterDesk：保留 RustDesk 设备 ID 的迁移部署

使用 [UNITRONIX/BetterDesk v3.5.4](https://github.com/UNITRONIX/BetterDesk/releases/tag/v3.5.4) 官方单容器镜像，包含信令、中继和管理面板。版本和镜像摘要固定，避免迁移时镜像变动；已确认镜像提供 amd64 / arm64。

## 这份 RustDesk 数据能保留什么

已对本目录提供的离线副本进行演练：数据库完整性检查通过，**28 条设备记录全部迁移**；每条 `id`、`uuid` 和设备公钥 `pk` 与源数据一致，服务器公私钥文件逐字节一致。

只读取主数据库时是 27 条，包含 WAL 后是 28 条，说明 WAL 中确有不能丢失的记录。

旧数据库是 `peer` 表，新版 Go 服务使用 `peers` 表。**不能仅将旧目录挂载给 BetterDesk，也不能只复制主数据库而遗漏 WAL。** `prepare-migration.py` 使用官方 v3.5.4 `rust2go` 工具转换，并验证结果；UUID 按上游要求从 BLOB 转成十六进制文本，而不是重新生成。工具下载后校验固定 SHA-256。

保留 ID 的条件：

- 保留服务器 `id_ed25519` 和 `id_ed25519.pub`。
- 完整迁移设备 ID、UUID、设备公钥；客户端也保留原有配置和身份文件，不重装或重置 ID。
- 客户端原来的 ID / 中继服务器地址继续指向新服务。本备份的 systemd 配置使用 `101.132.103.49:21117`；`.env.example` 沿用它，但上线前需确认地址仍有效。换服务器时转移原 IP 或切换原域名解析；客户端直接配置旧 IP 时，仅改 DNS 无效。

这保证的是服务器端身份数据不丢失；实际客户端重连、远控和中继仍需切换后验收。旧开源服务里的 IP 不是可靠的机器身份。机器名称等信息取决于旧 `info` 和客户端后续上报，迁移不会凭空补全。

## 持久化与历史迁移资料

**当前部署已完成迁移。** `docker-compose.yaml` 只包含运行中的 `betterdesk` 服务，不再提供 `migrate` 服务；以下迁移步骤仅为历史记录，不能对已投入使用的卷重复执行。

运行数据全部放在 Podman 命名卷：`server-data` 保存设备库和服务器密钥，`console-data` 保存管理后台数据。Compose 自动加项目名前缀。`/etc/configs/betterdesk/.env` 仅存环境变量；迁移只在首次部署时手动执行，日常启动、重启和升级不再读取本地备份。

下面的 `data/` 仅是一次性迁移的中间目录，不是运行时持久化目录。

```text
docker-compose.yaml
.env.example              # 配置模板，复制到 /etc/configs/betterdesk/.env
prepare-migration.py
rustdesk/                 # 原始离线副本；不挂载、不改写、不提交 Git
data/                     # 一次性转换输出；禁止覆盖已有目录
  server/                 # 转换后的设备库、原服务器密钥
  console/                # 准备脚本预留空目录，不导入也不挂载
  source-backup/          # 原始 DB + WAL/SHM（若存在）+ 密钥，供恢复
  migration-report.json   # 设备数量、校验字段和源文件 SHA-256
```

Python 3 标准库即可运行脚本。官方这一版本仅发布 Linux amd64 迁移工具；ARM 服务器应在 Linux amd64 机器上准备数据，再完整传输 `data/`。脚本不执行旧目录里的 `hbbs` / `hbbr`。

## 上线步骤

在部署服务器执行；本说明不会自动停止服务或修改网络。

1. 准备配置并预拉镜像：

   ```bash
   cd docker-compose/betterdesk
   sudo install -d -m 700 /etc/configs/betterdesk
   sudo install -m 600 .env.example /etc/configs/betterdesk/.env
   # 编辑 /etc/configs/betterdesk/.env：确认 RELAY_SERVERS，设置相同的强密码到 INIT_ADMIN_PASS 与 DEFAULT_ADMIN_PASSWORD。
   podman compose config >/dev/null
   podman compose pull
   ```

   `.env` 经绝对路径 `env_file` 加载；仓库目录无需保存 `.env`，运行数据仍保存在命名卷。面板映射为 `0.0.0.0:5000:5000`，可从内网访问；网闸仅转发明确需要的端口，勿将 `admin/admin` 的面板暴露公网。`RELAY_SERVERS` 是下发给客户端的可达地址，不能写成监听地址 `0.0.0.0`；应填写网闸对客户端提供的域名或 IP 加端口。

2. 安排切换窗口，停止旧服务，取得**最终一致副本**：

   ```bash
   sudo systemctl stop rustdesk-hbbs rustdesk-hbbr
   ```

   若旧服务实际由 Docker 管理，应停止对应旧容器。不要让旧、新服务同时占用同一地址端口。
   备份整个 `/var/lib/rustdesk`，确认有数据库及两份密钥；停机后的数据库若仍有 `-wal` / `-shm`，一并保留。将最终副本放在独立目录，勿将不同时间的 DB 和 WAL 混用。本仓库的 `rustdesk/` 只是上传时的副本，不能假定它就是切换时最新数据。

3. 从已停止的源目录或最终离线副本生成新数据：

   ```bash
   python3 prepare-migration.py --source /path/to/final-rustdesk-backup --source-stopped
   # 仅针对这里已有的离线副本做部署/演练时：
   # python3 prepare-migration.py --source ./rustdesk --source-stopped
   ```

   `--source-stopped` 是操作者对源已停止或副本已离线的确认，脚本不能替你检测远端服务。它在临时副本上读取 WAL，使用 SQLite backup API 生成完整快照，再转换并逐条验收；任何身份不一致、重复 ID、空库、损坏、源文件变动均中止。不会覆盖已有 `data/`，也不允许输出到源目录内。

   网络受限时，可事先下载官方 `migrate-linux-amd64`，使用 `--migrator /path/to/migrate-linux-amd64`，仍会校验固定摘要。演练请加 `--output /path/to/betterdesk-rehearsal`，正式切换重新使用最终备份，不能直接复用过期演练结果。

4. 历史首次导入已完成：转换后的设备库和原服务器密钥已导入 `betterdesk_server-data` 卷，面板数据在 `betterdesk_console-data` 卷。现有 Compose 不再提供导入服务；**不要对运行中的命名卷重复导入或覆盖**。

5. 检查目标主机端口和防火墙，然后启动：

   ```bash
   sudo ss -lntup
   podman compose up -d
   podman compose ps
   podman compose logs --tail=100 betterdesk
   ```

   对客户端开放 TCP 21115–21119、UDP 21116；21121 是本单容器布局的客户端 HTTP API。5000 是面板，和客户端 API 不同。外网登录 API 应通过 HTTPS 反代保护。Compose 使用显式端口映射，不使用 host 网络。服务只挂载命名卷；卷内缺少设备库或服务器密钥会拒绝启动，防止误用空库和新密钥。

   `ENROLLMENT_MODE=open` 保持旧开源 RustDesk 的注册行为。若日后要改成管理审批模式，需要同时调整 Compose 环境变量。

迁移验收完成后，本地 `data/` 不再参与运行，可移走归档；原始 `rustdesk/` 备份应保留供回滚。以后只需 `podman compose up -d`。`podman compose down` 会保留命名卷，**不要使用 `down -v`**，否则会删除运行数据。

## 验收与回滚

- 面板使用 `/etc/configs/betterdesk/.env` 里设置的管理员账号密码，首次启动后持久化；之后只改环境文件不会重置已有账号。
- 核对面板服务器公钥与原 `id_ed25519.pub` 一致。
- 核对原有 28 条设备（或最终备份记录数）和抽样机器的 ID。未上线设备显示离线不代表身份丢失；上游说明部分客户端需要重启 RustDesk 后台服务才能重新注册。
- 至少两台现有客户端验证重连、远程连接、文件传输，并单独验证经过中继的连接。重启 BetterDesk 后再次核对 ID 不变。
- 本地已验证的是离线迁移和 Compose 配置；命名卷导入、容器运行和真实客户端验收需在部署服务器执行。

失败时先 `podman compose down`，恢复原服务器地址/路由，再启动原 `rustdesk-hbbs` / `rustdesk-hbbr`。旧数据目录始终未被本方案挂载或改写，可以直接用原目录恢复。若从备份恢复，必须在旧服务停止时恢复同一份 DB/WAL/SHM 和密钥，先移走目标目录旧的 SQLite 边车文件，避免混用。**不要将 BetterDesk 转换后的数据库反向交给旧 hbbs。** 切换后新增设备/修改不在旧备份里，回滚会丢失这些新增状态，切换验收期间避免身份变更。

## 上游依据

- [v3.5.4 官方单容器 Compose](https://github.com/UNITRONIX/BetterDesk/blob/v3.5.4/docker-compose.quick.single.yml)
- [v3.5.4 rust2go 转换源码](https://github.com/UNITRONIX/BetterDesk/blob/v3.5.4/betterdesk-server/tools/migrate/main.go)
- [UUID 读取及比较](https://github.com/UNITRONIX/BetterDesk/blob/v3.5.4/betterdesk-server/signal/uuid_helpers.go)
- [密钥兼容实现](https://github.com/UNITRONIX/BetterDesk/blob/v3.5.4/betterdesk-server/crypto/keys.go)
- [迁移后的客户端在线状态说明](https://github.com/UNITRONIX/BetterDesk/blob/v3.5.4/docs/troubleshooting/SERVER_MIGRATION.md)

旧 DB、密钥和迁移中间目录均被本目录 `.gitignore` 排除；运行数据保存在 Podman 命名卷，环境文件位于仓库外的 `/etc/configs/betterdesk/.env`，勿提交其内容。
