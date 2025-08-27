#!/bin/bash

# 脚本必须以 root 权限运行
if [ "$(id -u)" -ne 0 ]; then
  echo "错误：请以 root 用户身份运行此脚本。" >&2
  exit 1
fi

# --- 功能函数 ---

# 安装 Fail2Ban
install_fail2ban() {
    if ! command -v fail2ban-client &> /dev/null; then
        echo "Fail2Ban 未安装，正在尝试..."
        if command -v apt-get &> /dev/null; then
            apt-get update && apt-get install -y fail2ban
        elif command -v yum &> /dev/null; then
            yum install -y epel-release && yum install -y fail2ban
        else
            echo "错误：无法识别您的包管理器，请手动安装 Fail2Ban。"
            return 1
        fi
        echo "Fail2Ban 安装成功。"
    else
        echo "Fail2Ban 已经安装。"
    fi
}

# 配置 Fail2Ban (创建 jail.local)
configure_fail2ban() {
    echo "正在创建 /etc/fail2ban/jail.local 配置文件..."
    
    # 使用 cat 和 EOF 创建文件，保留缩进和格式
    cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 600
findtime = 300
maxretry = 5
banaction = ufw
action = %(action_mwl)s

[sshd]
ignoreip = 127.0.0.1/8
enabled = true
filter = sshd
port = 66
maxretry = 2
findtime = 300
bantime = 30d
banaction = ufw
action = %(action_mwl)s
logpath = /var/log/auth.log
EOF

    echo "配置文件创建成功。"
    echo "已为 sshd 启用保护，规则为：5分钟内密码错误2次，封禁30天。"
    echo "您可以通过编辑 /etc/fail2ban/jail.local 文件来修改配置。"
}

# 查看 Fail2Ban 状态
show_status() {
    echo "--- Fail2Ban 服务状态 ---"
    systemctl status fail2ban --no-pager
    echo -e "\n--- 当前活动的 Jails ---"
    fail2ban-client status
    echo -e "\n--- SSHD Jail 详细状态 ---"
    fail2ban-client status sshd
}

# 解封 IP 地址
unban_ip() {
    read -p "请输入要解封的 IP 地址: " ip_address
    if [ -z "$ip_address" ]; then
        echo "IP 地址不能为空。"
        return
    fi
    
    echo "正在尝试从 sshd jail 中解封 $ip_address..."
    fail2ban-client set sshd unbanip "$ip_address"
    
    # 检查解封结果
    if fail2ban-client status sshd | grep -q "$ip_address"; then
        echo "错误：解封 $ip_address 失败，请检查IP是否正确或已被封禁。"
    else
        echo "成功解封 $ip_address。"
    fi
}

# --- 主菜单循环 ---
while true; do
    echo -e "\n============================="
    echo "      Fail2Ban 管理脚本"
    echo "============================="
    echo "1. 安装 Fail2Ban"
    echo "2. 配置 SSHD 防护 (创建 jail.local)"
    echo "3. 启动并设为开机自启"
    echo "4. 停止并禁用开机自启"
    echo "5. 查看状态"
    echo "6. 手动解封 IP"
    echo "7. 退出"
    echo "-----------------------------"
    read -p "请输入您的选择 [1-7]: " main_choice

    case $main_choice in
        1) install_fail2ban ;; 
        2) configure_fail2ban ;; 
        3) echo "正在启动 Fail2Ban..." && systemctl enable --now fail2ban && echo "服务已启动并设为开机自启。" ;; 
        4) echo "正在停止 Fail2Ban..." && systemctl disable --now fail2ban && echo "服务已停止并禁用开机自启。" ;; 
        5) show_status ;; 
        6) unban_ip ;; 
        7) echo "再见!"; exit 0 ;; 
        *) echo "无效的选择，请重试。" ;; 
    esac
done
