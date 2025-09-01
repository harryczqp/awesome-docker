#!/bin/bash

#================================================================================
# 脚本名称: ssh_user_manager.sh
# 描述:     一个通过交互式菜单管理 SSH 服务和系统用户的脚本。
# 功能:
#           - SSH 管理:
#             1. 修改 SSH 端口
#             2. 启用 RSA 密钥验证并生成密钥
#             3. 启用/禁用密码登录
#             4. 启用/禁用 root 用户远程登录
#             5. 回滚到初始配置
#             6. 重启 SSH 服务
#           - 用户和组管理:
#             1. 新增用户组
#             2. 新增用户 (支持添加到现有组)
#             3. 禁用/启用用户
#             4. 删除用户
#             5. 修改用户 Sudo 权限
#================================================================================

# --- 全局变量 ---
# SSH 配置文件的路径
SSH_CONFIG="/etc/ssh/sshd_config"
# 备份文件的路径和名称 (简化为单个文件)
BACKUP_FILE="/etc/ssh/sshd_config.bak.script"
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
        # 备份主配置文件
        echo "正在备份当前 SSH 配置文件到: $BACKUP_FILE ..."
        cp "$SSH_CONFIG" "$BACKUP_FILE"
        if [ $? -eq 0 ]; then
            echo "备份成功。"
            BACKUP_CREATED=1
        else
            echo "错误：备份失败！脚本将退出以确保安全。"
            exit 1
        fi
        # 同时备份 include 目录
        local include_dir
        include_dir=$(dirname "$SSH_CONFIG")/sshd_config.d
        if [ -d "$include_dir" ]; then
            echo "正在备份 include 目录: $include_dir"
            cp -r "$include_dir" "${BACKUP_FILE}.d"
        fi
    fi
}

# --- 已更新：更可靠地查找所有相关的 SSH 配置文件 ---
get_all_ssh_config_files() {
    local files=("$SSH_CONFIG")
    if [ -r "$SSH_CONFIG" ]; then
        # 读取所有 include 模式
        local patterns
        patterns=$(grep -E "^[[:space:]]*Include" "$SSH_CONFIG" | awk '{print $2}')
        
        for pattern in $patterns; do
            # 直接使用 shell 的 glob 扩展，更安全可靠
            local expanded_files=( $pattern )
            # 检查 glob 是否匹配到任何文件，以避免添加文字 "* .conf"
            if [ ${#expanded_files[@]} -gt 0 ] && [ -e "${expanded_files[0]}" ]; then
                files+=("${expanded_files[@]}")
            fi
        done
    fi
    # 返回一个唯一的、以空格分隔的文件列表
    echo "${files[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '
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

# --- SSH 核心功能函数 ---

# 1. 修改 SSH 端口
change_ssh_port() {
    current_port=$(grep -hE "^[[:space:]]*#?[[:space:]]*Port" $(get_all_ssh_config_files) | awk '{print $2}' | tail -n 1)
    echo "当前 SSH 端口是: ${current_port:-22}"
    read -p "请输入新的 SSH 端口号 (1-65535): " new_port

    if ! [[ "$new_port" =~ ^[0-9]+$ ]] || [ "$new_port" -lt 1 ] || [ "$new_port" -gt 65535 ]; then
        echo "错误：无效的端口号。"
        return
    fi

    create_backup
    
    local all_configs
    all_configs=$(get_all_ssh_config_files)
    echo "正在检查并清理以下配置文件中的 Port 设置: $all_configs"
    for config_file in $all_configs; do
        sed -i '/^[[:space:]]*#\?[[:space:]]*Port/d' "$config_file"
    done
    
    echo "Port ${new_port}" >> "$SSH_CONFIG"
    
    if [ $? -eq 0 ]; then
        echo "配置文件已更新。SSH 端口已修改为: $new_port"
        echo "提醒：如果您的服务器启用了防火墙，请确保放行新的端口 ${new_port}。"
        restart_ssh_service
    else
        echo "错误：修改配置文件失败！"
    fi
}


# 2. 启用 RSA 密钥验证
enable_rsa_auth() {
    create_backup
    
    local all_configs
    all_configs=$(get_all_ssh_config_files)
    echo "正在检查并清理以下配置文件中的密钥认证设置: $all_configs"
    for config_file in $all_configs; do
        sed -i '/^[[:space:]]*#\?[[:space:]]*PubkeyAuthentication/d' "$config_file"
        sed -i '/^[[:space:]]*#\?[[:space:]]*RSAAuthentication/d' "$config_file"
    done

    echo "PubkeyAuthentication yes" >> "$SSH_CONFIG"
    echo "RSAAuthentication yes" >> "$SSH_CONFIG"
    echo "密钥登录已在配置文件中启用。"
    
    read -p "是否需要为您生成一个新的 RSA 密钥对？(y/n): " generate_key
    if [[ "$generate_key" =~ ^[Yy]$ ]]; then
        read -p "请输入保存密钥的文件路径 (例如: /root/.ssh/id_rsa)，直接回车将使用默认值: " key_path
        [ -z "$key_path" ] && key_path="/root/.ssh/id_rsa"
        mkdir -p "$(dirname "$key_path")"
        ssh-keygen -t rsa -b 4096 -N "" -f "$key_path" -q
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
    current_status=$(grep -hE "^[[:space:]]*#?[[:space:]]*PasswordAuthentication" $(get_all_ssh_config_files) | awk '{print $2}' | tail -n 1)
    if [[ "$current_status" == "yes" ]]; then
        read -p "当前允许密码登录。您想禁用吗？(y/n): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            create_backup
            local all_configs
            all_configs=$(get_all_ssh_config_files)
            echo "正在禁用所有形式的密码登录，清理以下文件: $all_configs"
            for config_file in $all_configs; do
                sed -i '/^[[:space:]]*#\?[[:space:]]*PasswordAuthentication/d' "$config_file"
                sed -i '/^[[:space:]]*#\?[[:space:]]*ChallengeResponseAuthentication/d' "$config_file"
            done
            echo "PasswordAuthentication no" >> "$SSH_CONFIG"
            echo "ChallengeResponseAuthentication no" >> "$SSH_CONFIG"
            echo "密码登录配置已更新。"
        else
            echo "操作取消。"; return;
        fi
    else
        read -p "当前禁止密码登录。您想启用吗？(y/n): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            create_backup
            local all_configs
            all_configs=$(get_all_ssh_config_files)
            echo "正在启用密码登录，清理以下文件: $all_configs"
            for config_file in $all_configs; do
                sed -i '/^[[:space:]]*#\?[[:space:]]*PasswordAuthentication/d' "$config_file"
                sed -i '/^[[:space:]]*#\?[[:space:]]*ChallengeResponseAuthentication/d' "$config_file"
            done
            echo "PasswordAuthentication yes" >> "$SSH_CONFIG"
            echo "ChallengeResponseAuthentication yes" >> "$SSH_CONFIG"
            echo "密码登录配置已更新。"
        else
            echo "操作取消。"; return;
        fi
    fi
    restart_ssh_service
}

# 4. 切换 root 远程登录
toggle_root_login() {
    current_status=$(grep -hE "^[[:space:]]*#?[[:space:]]*PermitRootLogin" $(get_all_ssh_config_files) | awk '{print $2}' | tail -n 1)
    if [[ "$current_status" == "yes" ]]; then
        read -p "当前允许 root 远程登录。您想禁用吗？(y/n): " choice
        [[ "$choice" =~ ^[Yy]$ ]] && new_status="no" || { echo "操作取消。"; return; }
    else
        read -p "当前禁止 root 远程登录。您想允许吗？(y/n): " choice
        [[ "$choice" =~ ^[Yy]$ ]] && new_status="yes" || { echo "操作取消。"; return; }
    fi

    create_backup
    local all_configs
    all_configs=$(get_all_ssh_config_files)
    echo "正在检查并清理以下配置文件中的 PermitRootLogin 设置: $all_configs"
    for config_file in $all_configs; do
        sed -i '/^[[:space:]]*#\?[[:space:]]*PermitRootLogin/d' "$config_file"
    done

    echo "PermitRootLogin ${new_status}" >> "$SSH_CONFIG"
    
    echo "Root 用户登录配置已更新为: $new_status"
    restart_ssh_service
}

# 5. 回滚所有更改
rollback_changes() {
    if [ -f "$BACKUP_FILE" ]; then
        read -p "您确定要回滚所有更改，恢复到备份文件 '$BACKUP_FILE' 的状态吗？(y/n): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            echo "正在从备份恢复主配置文件..."
            cp "$BACKUP_FILE" "$SSH_CONFIG"
            [ $? -eq 0 ] && echo "主配置文件恢复成功。" || echo "错误：主配置文件恢复失败！"
            
            local include_dir_backup="${BACKUP_FILE}.d"
            if [ -d "$include_dir_backup" ]; then
                echo "正在从备份恢复 include 目录..."
                local include_dir
                include_dir=$(dirname "$SSH_CONFIG")/sshd_config.d
                rm -rf "$include_dir"
                cp -r "$include_dir_backup" "$include_dir"
                [ $? -eq 0 ] && echo "include 目录恢复成功。" || echo "错误：include 目录恢复失败！"
            fi
            
            restart_ssh_service
        else
            echo "回滚操作已取消。"
        fi
    else
        echo "错误：找不到备份文件。无法执行回滚操作。"
    fi
}

# --- 用户和组管理功能 ---

# 1. 新增用户组
add_group() {
    read -p "请输入要创建的用户组名称: " group_name
    if [ -z "$group_name" ]; then echo "错误：用户组名称不能为空。"; return; fi
    if grep -qE "^${group_name}:" /etc/group; then
        echo "错误：用户组 '$group_name' 已存在。"
    else
        groupadd "$group_name"
        [ $? -eq 0 ] && echo "用户组 '$group_name' 创建成功。" || echo "错误：用户组创建失败。"
    fi
}

# 2. 新增用户
add_user() {
    read -p "请输入要创建的用户名: " username
    if [ -z "$username" ]; then echo "错误：用户名不能为空。"; return; fi
    if id "$username" &>/dev/null; then
        echo "错误：用户 '$username' 已存在。"
    else
        read -p "是否为用户 '$username' 创建家目录？(y/n, 默认 y): " create_home
        home_option="-m"
        [[ "$create_home" =~ ^[Nn]$ ]] && home_option=""
        
        useradd $home_option -s /bin/bash "$username"
        if [ $? -eq 0 ]; then
            echo "用户 '$username' 创建成功。"
            
            read -p "是否要将用户 '$username' 添加到已存在的用户组？(y/n): " add_to_group
            if [[ "$add_to_group" =~ ^[Yy]$ ]]; then
                read -p "请输入要加入的用户组名称: " group_name_to_join
                if [ -z "$group_name_to_join" ]; then
                    echo "提示：用户组名称不能为空，跳过操作。"
                # 检查用户组是否存在
                elif grep -qE "^${group_name_to_join}:" /etc/group; then
                    usermod -aG "$group_name_to_join" "$username"
                    if [ $? -eq 0 ]; then
                        echo "用户 '$username' 已成功添加到用户组 '$group_name_to_join'。"
                    else
                        echo "错误：将用户添加到组失败。"
                    fi
                else
                    echo "错误：用户组 '$group_name_to_join' 不存在。"
                fi
            fi
            echo "请为新用户设置密码："
            passwd "$username"
        else
            echo "错误：用户创建失败。"
        fi
    fi
}

# 3. 禁用/启用用户
toggle_user_status() {
    read -p "请输入要操作的用户名: " username
    if ! id "$username" &>/dev/null; then echo "错误：用户 '$username' 不存在。"; return; fi
    
    # 检查账户是否被锁定
    if passwd -S "$username" | grep -q " L "; then
        read -p "用户 '$username' 当前被禁用。您想启用他吗？(y/n): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            usermod -U "$username"
            [ $? -eq 0 ] && echo "用户 '$username' 已启用。" || echo "错误：操作失败。"
        fi
    else
        read -p "用户 '$username' 当前是启用状态。您想禁用他吗？(y/n): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            usermod -L "$username"
            [ $? -eq 0 ] && echo "用户 '$username' 已禁用。" || echo "错误：操作失败。"
        fi
    fi
}

# 4. 删除用户
delete_user() {
    read -p "请输入要删除的用户名: " username
    if ! id "$username" &>/dev/null; then echo "错误：用户 '$username' 不存在。"; return; fi
    
    read -p "您确定要删除用户 '$username' 吗？这是一个不可逆操作！(y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        read -p "是否同时删除该用户的家目录 (/home/$username)？(y/n): " delete_home
        del_home_option=""
        [[ "$delete_home" =~ ^[Yy]$ ]] && del_home_option="-r"
        
        userdel $del_home_option "$username"
        [ $? -eq 0 ] && echo "用户 '$username' 已被删除。" || echo "错误：用户删除失败。"
    else
        echo "操作已取消。"
    fi
}

# 5. 修改用户 Sudo 权限
manage_sudo_privileges() {
    # 自动检测 sudo 组名 (wheel for RHEL/CentOS, sudo for Debian/Ubuntu)
    if grep -qE "^wheel:.*" /etc/group; then
        sudo_group="wheel"
    elif grep -qE "^sudo:.*" /etc/group; then
        sudo_group="sudo"
    else
        echo "错误：无法确定此系统上的 sudo 用户组 (wheel/sudo)。"
        return
    fi
    
    read -p "请输入要操作的用户名: " username
    if ! id "$username" &>/dev/null; then echo "错误：用户 '$username' 不存在。"; return; fi

    if groups "$username" | grep -q "\b$sudo_group\b"; then
        read -p "用户 '$username' 拥有 Sudo 权限。您想撤销吗？(y/n): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            gpasswd -d "$username" "$sudo_group"
            [ $? -eq 0 ] && echo "已撤销 '$username' 的 Sudo 权限。" || echo "错误：操作失败。"
        fi
    else
        read -p "用户 '$username' 没有 Sudo 权限。您想授予吗？(y/n): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            usermod -aG "$sudo_group" "$username"
            [ $? -eq 0 ] && echo "已授予 '$username' Sudo 权限。" || echo "错误：操作失败。"
        fi
    fi
}


# --- 子菜单：用户和组管理 ---
show_user_menu() {
    while true; do
        echo ""
        echo "-----------------------------------------"
        echo "          用户和组管理"
        echo "-----------------------------------------"
        echo "  1. 新增用户组"
        echo "  2. 新增用户"
        echo "  3. 禁用/启用用户"
        echo "  4. 删除用户"
        echo "  5. 修改用户 Sudo 权限"
        echo "  6. 返回主菜单"
        echo "-----------------------------------------"
        read -p "请输入您的选择 [1-6]: " user_choice

        case $user_choice in
            1) add_group ;;
            2) add_user ;;
            3) toggle_user_status ;;
            4) delete_user ;;
            5) manage_sudo_privileges ;;
            6) break ;;
            *) echo "无效的输入，请输入 1 到 6 之间的数字。" ;;
        esac
        [ "$user_choice" != "6" ] && read -p "按 [Enter] 键继续..."
    done
}

# --- 主菜单 ---
show_main_menu() {
    echo ""
    echo "========================================="
    echo "        SSH 与用户综合管理脚本"
    echo "========================================="
    echo "  1. 修改 SSH 端口"
    echo "  2. 启用 RSA 密钥验证 (并生成密钥)"
    echo "  3. 启用/禁用密码登录"
    echo "  4. 启用/禁用 root 用户远程登录"
    echo "  5. 用户和组管理"
    echo "  6. 重启 SSH 服务"
    echo "  7. 回滚 SSH 配置"
    echo "  8. 退出脚本"
    echo "========================================="
    read -p "请输入您的选择 [1-8]: " choice
}

# --- 主程序 ---
main() {
    check_root
    while true; do
        show_main_menu
        case $choice in
            1) change_ssh_port ;;
            2) enable_rsa_auth ;;
            3) toggle_password_auth ;;
            4) toggle_root_login ;;
            5) show_user_menu ;;
            6) restart_ssh_service ;;
            7) rollback_changes ;;
            8) echo "感谢使用，脚本退出。"; exit 0 ;;
            *) echo "无效的输入，请输入 1 到 8 之间的数字。" ;;
        esac
        if [[ "$choice" != "5" && "$choice" != "8" ]]; then
             read -p "按 [Enter] 键返回主菜单..."
        fi
    done
}

# 启动主程序
main
