#!/bin/bash

# 脚本必须以 root 权限运行
if [ "$(id -u)" -ne 0 ]; then
  echo "错误：请以 root 用户身份运行此脚本。" >&2
  exit 1
fi

# --- 功能函数 ---

# 从 /etc/ssh/sshd_config 获取 SSH 端口，失败则返回 22
get_ssh_port() {
    # 使用 grep 和 awk 精确提取端口号，如果找不到则输出 22
    grep -i '^\s*Port' /etc/ssh/sshd_config | awk '{print $2}' | head -n 1 || echo "22"
}

# 安装 UFW
install_ufw() {
    if ! command -v ufw &> /dev/null; then
        echo "UFW 未安装，正在尝试..."
        if command -v apt-get &> /dev/null; then
            apt-get update && apt-get install -y ufw
        elif command -v yum &> /dev/null; then
            yum install -y epel-release && yum install -y ufw
        else
            echo "错误：无法识别您的包管理器，请手动安装 UFW。"
            return 1
        fi
        echo "UFW 安装成功。"
    else
        echo "UFW 已经安装。"
    fi
}

# 添加或更新 SSH 防火墙规则
handle_ssh_rule() {
    local CURRENT_SSH_PORT=$(get_ssh_port)
    echo "系统当前配置的 SSH 端口是: $CURRENT_SSH_PORT"

    read -p "是否要为该端口添加或更新防火墙规则? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
        echo "操作已取消。"
        return
    fi

    # 通过特定注释来查找此脚本之前管理的 SSH 规则
    # 'ufw status numbered' 输出格式为 [ 1] 22/tcp ALLOW IN Anywhere
    OLD_RULE_NUM=$(ufw status numbered | grep "'SSH_RULE_MANAGED'" | awk -F'[][]' '{print $2}')

    if [ -n "$OLD_RULE_NUM" ]; then
        echo "找到了由本脚本管理的旧规则 (编号 #$OLD_RULE_NUM)，正在删除..."
        yes | ufw delete $OLD_RULE_NUM > /dev/null
    fi

    # 添加带注释的新规则，以便下次可以识别
    echo "正在添加新规则: 'allow $CURRENT_SSH_PORT/tcp' בו..."
    ufw allow $CURRENT_SSH_PORT/tcp comment 'SSH_RULE_MANAGED'
    echo "操作完成。"
    ufw status
}

# 管理其他规则的子菜单
manage_other_rules() {
    while true; do
        echo -e "\n--- 管理其他规则 ---"
        echo "1. 允许 (allow) 端口/服务"
        echo "2. 拒绝 (deny) 端口/服务"
        echo "3. 删除规则 (按编号)"
        echo "4. 返回主菜单"
        read -p "请选择 [1-4]: " choice

        case $choice in
            1)
                read -p "输入要允许的端口/服务 (例如: 80, 443/tcp): " rule
                [ -n "$rule" ] && ufw allow "$rule" && ufw status
                ;;
            2)
                read -p "输入要拒绝的端口/服务 (例如: 3306): " rule
                [ -n "$rule" ] && ufw deny "$rule" && ufw status
                ;;
            3)
                echo "当前规则列表:"
                ufw status numbered
                read -p "输入要删除的规则编号: " num
                if [[ "$num" =~ ^[0-9]+$ ]]; then
                    yes | ufw delete "$num"
                    ufw status numbered
                else
                    echo "无效的编号。"
                fi
                ;;
            4) break ;; 
            *) echo "无效选项。" ;; 
        esac
    done
}

# --- 主菜单循环 ---
while true; do
    echo -e "\n============================="
    echo "      UFW 防火墙管理器"
    echo "============================="
    # 简洁地显示当前防火墙状态
    ufw status | head -n 1
    echo "-----------------------------"
    echo "1. 查看详细状态和规则"
    echo "2. 安装 UFW"
    echo "3. 启用防火墙"
    echo "4. 禁用防火墙"
    echo "5. 添加/更新 SSH 端口规则"
    echo "6. 管理其他端口规则"
    echo "7. 退出"
    echo "-----------------------------"
    read -p "请输入您的选择 [1-7]: " main_choice

    case $main_choice in
        1) ufw status verbose ;; 
        2) install_ufw ;; 
        3) echo "正在启用防火墙..." && yes | ufw enable && ufw status ;; 
        4) echo "正在禁用防火墙..." && ufw disable && ufw status ;; 
        5) handle_ssh_rule ;; 
        6) manage_other_rules ;; 
        7) echo "再见!"; exit 0 ;; 
        *) echo "无效的选择，请重试。" ;; 
    esac
done
