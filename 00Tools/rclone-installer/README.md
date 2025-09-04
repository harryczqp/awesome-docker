# rclone 交互式管理脚本

这是一个用于在 Linux 系统上管理 [rclone](https://rclone.org/) 安装和 systemd 服务的交互式 Bash 脚本。它可以帮助您轻松地安装、卸载 rclone，并创建和管理用于云存储挂载的 systemd 服务。

## 主要功能

*   **安装/更新 rclone**: 自动从 rclone 官网下载并执行官方安装脚本，完成 rclone 的安装或更新。
*   **卸载 rclone**: 卸载 rclone 主程序和相关的 man 手册页，并提供选项让您决定是否删除 rclone 的配置文件目录。
*   **创建 systemd 挂载服务**: 以交互方式引导您创建一个 systemd 服务，实现开机自动挂载 rclone 远端存储。
    *   支持加密的 `rclone.conf` 配置文件，脚本会引导您输入密码，并将其安全地存储在权限受限的脚本中。
*   **删除 systemd 服务**: 停止、禁用并删除之前创建的 rclone 挂载服务，同时也会提示是否删除关联的密码脚本。
*   **查看服务日志**: 提供一个便捷的菜单来使用 `journalctl` 查看指定 rclone 挂载服务的日志，方便您进行调试。

## 使用方法

首先，确保您已经将脚本下载到您的机器上。然后，在脚本所在的目录中执行以下命令来启动交互式管理器：

```bash
bash install_rclone.sh
```

脚本启动后，您会看到一个包含以下选项的菜单：

```
rclone Interactive Manager
--------------------------
1) Install/Update rclone
2) Uninstall rclone
3) Create systemd service for mount
4) Delete systemd service
5) View Service Logs
6) Exit
Please select an option:
```

### 菜单选项详解

1.  **Install/Update rclone (安装/更新 rclone)**
    *   选择此项将开始 rclone 的安装或更新流程。脚本会从 rclone 官网下载最新的安装脚本并执行。

2.  **Uninstall rclone (卸载 rclone)**
    *   此选项将帮助您从系统中移除 rclone。它会删除 rclone 二进制文件和 man 手册页。
    *   在卸载过程中，脚本会询问您是否需要一并删除位于 `~/.config/rclone` 的配置文件目录。

3.  **Create systemd service for mount (创建 systemd 挂载服务)**
    *   这是脚本的核心功能，用于将您的云存储挂载到本地文件系统。
    *   脚本会依次询问以下信息：
        *   **rclone 远端和路径**: 例如 `onedrive:backup` 或 `gdrive_crypt:/`。
        *   **本地挂载点**: 您希望将云存储挂载到的本地目录，例如 `/mnt/onedrive`。如果目录不存在，脚本会提示您创建。
        *   **运行服务的用户**: 默认是当前用户，您可以指定其他用户。
    *   如果您的 rclone 配置文件 (`rclone.conf`) 设置了密码，脚本会提示您输入密码，并为 systemd 服务创建一个专门的密码脚本，以确保安全。
    *   最后，脚本会创建、启用并立即启动 systemd 服务，让挂载即刻生效。

4.  **Delete systemd service (删除 systemd 服务)**
    *   如果您想移除一个挂载服务，请选择此项。
    *   脚本会列出所有由它创建的 rclone 服务，让您选择要删除哪一个。
    *   删除过程包括停止服务、禁用服务、删除 systemd 配置文件以及相关的密码脚本（如果存在）。

5.  **View Service Logs (查看服务日志)**
    *   当您的挂载出现问题时，此功能非常有用。
    *   它会列出所有可用的 rclone 服务，您可以选择一个来查看其日志。提供了多种查看模式（如实时跟踪、查看全部、查看最后100行等）。

6.  **Exit (退出)**
    *   退出本脚本。

## 注意事项

*   脚本中的大多数操作（如安装、卸载、管理 systemd 服务）都需要 `sudo` 权限。脚本会在需要时自动调用 `sudo`，届时您可能需要输入您的用户密码。