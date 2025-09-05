# Docker 卷备份与管理工具

`backup_volumes.py` 是一个 Python 脚本，旨在简化 Docker 卷的备份、恢复和日常管理任务。

## 功能特性

- **列出卷**: 显示所有 Docker 卷以及正在使用它们的容器。
- **智能备份**: 仅备份正在被容器使用的卷，并将它们打包成一个单独的 `.tar` 文件。
- **安全停止 (可选)**: 在备份前自动停止相关容器，并在备份后重启，以确保数据一致性。
- **自动重命名**: 在备份压缩包内，卷的名称会从 `volume_name` 智能转换为 `container_name_data`，便于识别。
- **交互式恢复**: 引导用户从列表中选择备份文件进行恢复。
- **清理未使用卷**: 查找并删除所有当前未被任何容器使用的卷。
- **自动清理旧备份**: 根据设置的保留天数，在每次备份后自动删除旧的备份文件。

## 先决条件

- Python 3
- Docker Engine 已安装并正在运行。
- 运行此脚本的用户需要有权限执行 `docker` 命令 (通常意味着用户属于 `docker` 组)。

## 配置 (通过环境变量)

脚本的行为可以通过设置以下环境变量进行配置：

| 环境变量 | 描述 | 默认值 |
| :--- | :--- | :--- |
| `DOCKER_BACKUP_DIR` | 指定存放备份文件 (`.tar`) 的目录。 | `/mnt/onedrive` |
| `STOP_CONTAINERS_FOR_BACKUP` | 如果设置为 `true`、`1` 或 `yes`，脚本会在备份一个卷之前停止使用它的容器，并在完成后重启它们。 | `false` |
| `BACKUP_RETENTION_DAYS` | 设置备份文件的最长保留天数。每次成功备份后，脚本会删除超出此天数的旧备份。如果未设置，则不执行清理。 | (不清理) |

### 配置示例

```bash
# 将备份目录设置为 /mnt/backups
export DOCKER_BACKUP_DIR="/mnt/backups"

# 启用备份前停止容器的功能
export STOP_CONTAINERS_FOR_BACKUP=true

# 保留备份文件 7 天
export BACKUP_RETENTION_DAYS=7
```

## 使用方法

### 1. 列出所有卷

要查看系统上所有的 Docker 卷及其使用情况，请运行：

```bash
python backup_volumes.py list
```

### 2. 备份正在使用的卷

此命令会备份所有正在使用的卷，并在操作成功后根据 `BACKUP_RETENTION_DAYS` 清理旧备份。

```bash
python backup_volumes.py backup
```

### 3. 从备份恢复卷

恢复过程是交互式的。脚本会列出所有可用的备份文件供您选择。**此操作需要 root 权限**，因为它会直接向 `/var/lib/docker/volumes/` 目录写入数据。

```bash
sudo python backup_volumes.py restore
```

**警告**: 恢复操作会覆盖目标路径下任何同名的现有卷。

### 4. 清理未使用的卷

此命令会查找并提示您删除所有未被任何容器引用的卷。这是一个永久性删除操作，需要您手动确认。

```bash
python backup_volumes.py prune
```
