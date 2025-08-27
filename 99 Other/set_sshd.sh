#!/bin/bash

#================================================================================
# 脚本名称: ssh_manager.sh
# 描述:     一个通过交互式菜单管理和加固 SSH 服务的脚本。
# 功能:
#           1. 修改 SSH 端口
#           2. 启用 RSA 密钥验证并生成密钥
#           3. 启用/禁用密码登录
#           4. 启用/禁用 root 用户远程登录
#           5. 回滚到初始配置
#           6. 重启 SSH 服务
#================================================================================

# --- 全局变量 ---
# SSH 配置文件的路径
SSH_CONFIG="/etc/ssh/sshd_config"
# 备份文件的路径和名称，加入时间戳以防重复
BACKUP_FILE="/etc/ssh/sshd_config.bak.$(date +%F_%T)"
# 标记是否已创建备份
BACKUP_CREATED=0

# --- 基础函数 ---

# 检查脚本是否以 root 用户权限运行
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "错误：此脚本需要以 root 用户权限运行。"
        echo "请尝试使用 'sudo ./ssh_manager.sh' 命令运行。"
        exit 1
    fi
}

# 创建配置文件备份
create_backup() {
    if [ ! -f "$SSH_CONFIG" ]; then
        echo "错误：找不到 SSH 配置文件: $SSH_CONFIG"
        exit 1
    fi
    # 仅在首次修改前创建一次备份
    if [ $BACKUP_CREATED -eq 0 ]; then
        echo "正在备份当前 SSH 配置文件到: $BACKUP_FILE ..."
        cp "$SSH_CONFIG" "$BACKUP_FILE"
        if [ $? -eq 0 ]; then
            echo "备份成功。"
            BACKUP_CREATED=1
        else
            echo "错误：备份失败！脚本将退出以确保安全。"
            exit 1
        fi
    fi
}

# 重启 SSH 服务以应用更改
restart_ssh_service() {
    echo "正在尝试重启 SSH 服务以应用更改..."
    # 使用 systemctl (现代系统)
    if command -v systemctl &> /dev/null; then
        # 尝试常见的服务名称 sshd 和 ssh
        if systemctl is-active --quiet sshd; then
            systemctl restart sshd
        elif systemctl is-active --quiet ssh; then
            systemctl restart ssh
        else
            echo "警告：找不到正在运行的 sshd 或 ssh 服务。"
            return 1
        fi
    # 使用 service (旧版系统)
    elif command -v service &> /dev/null; then
        if service sshd status &> /dev/null; then
            service sshd restart
        elif service ssh status &> /dev/null; then
            service ssh restart
        else
            echo "警告：找不到 sshd 或 ssh 服务。"
            return 1
        fi
    else
        echo "错误：找不到 'systemctl' 或 'service' 命令。无法自动重启 SSH 服务。"
        echo "请手动重启 SSH 服务以应用配置。"
        return 1
    fi

    if [ $? -eq 0 ]; then
        echo "SSH 服务重启成功。"
    else
        echo "错误：SSH 服务重启失败！请检查配置文件语法是否有误: 'sshd -t'"
    fi
}

# --- 核心功能函数 ---

# 1. 修改 SSH 端口
change_ssh_port() {
    current_port=$(grep -E "^#?Port" "$SSH_CONFIG" | awk '{print $2}' | head -n 1)
    echo "当前 SSH 端口是: ${current_port:-22}"
    read -p "请输入新的 SSH 端口号 (1-65535): " new_port

    # 验证输入是否为有效端口号
    if ! [[ "$new_port" =~ ^[0-9]+$ ]] || [ "$new_port" -lt 1 ] || [ "$new_port" -gt 65535 ]; then
        echo "错误：无效的端口号。"
        return
    fi

    create_backup
    # 使用 sed 修改或添加 Port 配置
    if grep -qE "^#?Port" "$SSH_CONFIG"; then
        # 如果存在 Port 行（无论是否注释），则替换它
        sed -i "s/^#?Port.*/Port ${new_port}/" "$SSH_CONFIG"
    else
        # 如果不存在，则在文件末尾添加
        echo "Port ${new_port}" >> "$SSH_CONFIG"
    fi
    echo "SSH 端口已修改为: $new_port"
    echo "提醒：如果您的服务器启用了防火墙，请确保放行新的端口 ${new_port}。"
    restart_ssh_service
}

# 2. 启用 RSA 密钥验证
enable_rsa_auth() {
    create_backup
    echo "正在启用密钥登录..."
    # 确保 PubkeyAuthentication 和 RSAAuthentication 设置为 yes
    sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' "$SSH_CONFIG"
    sed -i 's/^#*RSAAuthentication.*/RSAAuthentication yes/' "$SSH_CONFIG"
    
    # 如果配置项不存在，则添加
    grep -q "^PubkeyAuthentication" "$SSH_CONFIG" || echo "PubkeyAuthentication yes" >> "$SSH_CONFIG"
    grep -q "^RSAAuthentication" "$SSH_CONFIG" || echo "RSAAuthentication yes" >> "$SSH_CONFIG"

    echo "密钥登录已在配置文件中启用。"

    read -p "是否需要为您生成一个新的 RSA 密钥对？(y/n): " generate_key
    if [[ "$generate_key" =~ ^[Yy]$ ]]; then
        read -p "请输入保存密钥的文件路径 (例如: /root/.ssh/id_rsa)，直接回车将使用默认值: " key_path
        # 如果用户未输入，则使用默认路径
        [ -z "$key_path" ] && key_path="/root/.ssh/id_rsa"
        
        # 创建目录（如果不存在）
        mkdir -p "$(dirname "$key_path")"
        
        # 生成密钥，-t 指定类型，-b 指定长度，-N "" 设置空密码，-f 指定路径
        ssh-keygen -t rsa -b 4096 -N "" -f "$key_path" -q
        
        # 将公钥添加到 authorized_keys 以允许登录
        cat "${key_path}.pub" >> "$(dirname "$key_path")/authorized_keys"
        chmod 600 "$(dirname "$key_path")/authorized_keys"
        
        echo -e "\n密钥对已生成！"
        echo "公钥已自动添加到 authorized_keys。"
        echo "------------------------- 私钥内容 -------------------------"
        cat "$key_path"
        echo "------------------------------------------------------------"
        echo "请务必妥善保管以上私钥，它将用于您的 SSH 客户端登录。"
    fi
    restart_ssh_service
}

# 3. 切换密码登录
toggle_password_auth() {
    current_status=$(grep -E "^#?PasswordAuthentication" "$SSH_CONFIG" | awk '{print $2}' | tail -n 1)
    if [[ "$current_status" == "yes" ]]; then
        echo "当前状态：允许密码登录。"
        read -p "您想禁用密码登录吗？(y/n): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            new_status="no"
            echo "操作：禁用密码登录。"
        else
            echo "操作取消。"
            return
        fi
    else
        echo "当前状态：禁止密码登录。"
        read -p "您想启用密码登录吗？(y/n): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            new_status="yes"
            echo "操作：启用密码登录。"
        else
            echo "操作取消。"
            return
        fi
    fi

    create_backup
    # 修改或添加 PasswordAuthentication 配置
    if grep -qE "^#?PasswordAuthentication" "$SSH_CONFIG"; then
        sed -i "s/^#?PasswordAuthentication.*/PasswordAuthentication ${new_status}/" "$SSH_CONFIG"
    else
        echo "PasswordAuthentication ${new_status}" >> "$SSH_CONFIG"
    fi
    echo "密码登录配置已更新。"
    restart_ssh_service
}

# 4. 切换 root 远程登录
toggle_root_login() {
    current_status=$(grep -E "^#?PermitRootLogin" "$SSH_CONFIG" | awk '{print $2}' | tail -n 1)
    if [[ "$current_status" == "yes" ]]; then
        echo "当前状态：允许 root 用户远程登录。"
        read -p "您想禁止 root 用户远程登录吗？(y/n): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            new_status="no"
            echo "操作：禁止 root 登录。"
        else
            echo "操作取消。"
            return
        fi
    else
        echo "当前状态：禁止 root 用户远程登录。"
        read -p "您想允许 root 用户远程登录吗？(y/n): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            new_status="yes"
            echo "操作：允许 root 登录。"
        else
            echo "操作取消。"
            return
        fi
    fi

    create_backup
    # 修改或添加 PermitRootLogin 配置
    if grep -qE "^#?PermitRootLogin" "$SSH_CONFIG"; then
        sed -i "s/^#?PermitRootLogin.*/PermitRootLogin ${new_status}/" "$SSH_CONFIG"
    else
        echo "PermitRootLogin ${new_status}" >> "$SSH_CONFIG"
    fi
    echo "Root 用户登录配置已更新。"
    restart_ssh_service
}

# 5. 回滚所有更改
rollback_changes() {
    if [ -f "$BACKUP_FILE" ]; then
        read -p "您确定要回滚所有更改，恢复到备份文件 '$BACKUP_FILE' 的状态吗？(y/n): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            echo "正在从备份恢复..."
            cp "$BACKUP_FILE" "$SSH_CONFIG"
            if [ $? -eq 0 ]; then
                echo "恢复成功。"
                restart_ssh_service
            else
                echo "错误：恢复失败！"
            fi
        else
            echo "回滚操作已取消。"
        fi
    else
        echo "错误：找不到备份文件。无法执行回滚操作。"
        echo "备份文件应在首次修改配置时自动创建。"
    fi
}

# --- 主菜单 ---
show_menu() {
    echo ""
    echo "========================================="
    echo "        SSH 安全管理脚本"
    echo "========================================="
    echo "  1. 修改 SSH 端口"
    echo "  2. 启用 RSA 密钥验证 (并生成密钥)"
    echo "  3. 启用/禁用密码登录"
    echo "  4. 启用/禁用 root 用户远程登录"
    echo "  5. 重启 SSH 服务"
    echo "  6. 回滚所有更改"
    echo "  7. 退出脚本"
    echo "========================================="
    read -p "请输入您的选择 [1-7]: " choice
}

# --- 主程序 ---
main() {
    check_root
    while true; do
        show_menu
        case $choice in
            1) change_ssh_port ;;
            2) enable_rsa_auth ;;
            3) toggle_password_auth ;;
            4) toggle_root_login ;;
            5) restart_ssh_service ;;
            6) rollback_changes ;;
            7) echo "感谢使用，脚本退出。"; exit 0 ;;
            *) echo "无效的输入，请输入 1 到 7 之间的数字。" ;;
        esac
        read -p "按 [Enter] 键返回主菜单..."
    done
}

# 启动主程序
main

