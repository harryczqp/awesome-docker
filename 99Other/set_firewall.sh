#!/bin/bash

# 脚本必须以 root 权限运行
if [ "$(id -u)" -ne 0 ]; then
  echo "错误：请以 root 用户身份运行此脚本。" >&2
  exit 1
fi

# --- 全局变量 ---
FORWARD_RULES_CONF="/etc/ufw/custom-forward-rules.conf"

# --- 功能函数 ---

# 从 /etc/ssh/sshd_config 获取 SSH 端口，失败则返回 22
get_ssh_port() {
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
    if [[ "$confirm" != "y" ]]; then echo "操作已取消。"; return; fi

    OLD_RULE_NUM=$(ufw status numbered | grep "'SSH_RULE_MANAGED'" | awk -F'[][]' '{print $2}')
    if [ -n "$OLD_RULE_NUM" ]; then
        echo "找到了由本脚本管理的旧规则 (编号 #$OLD_RULE_NUM)，正在删除..."
        yes | ufw delete $OLD_RULE_NUM > /dev/null
    fi
    echo "正在添加新规则: 'allow $CURRENT_SSH_PORT/tcp'..."
    ufw allow $CURRENT_SSH_PORT/tcp comment 'SSH_RULE_MANAGED'
    echo "操作完成。"; ufw status
}

# 管理其他规则的子菜单
manage_other_rules() {
    while true; do
        echo -e "\n--- 管理端口和IP规则 ---"
        echo "1. 允许 (allow) 端口/服务"
        echo "2. 拒绝 (deny) 端口/服务"
        echo "3. 允许 (allow) 来自IP的访问"
        echo "4. 拒绝 (deny) 来自IP的访问"
        echo "5. 删除规则 (按编号)"
        echo "6. 返回主菜单"
        read -p "请选择 [1-6]: " choice
        case $choice in
            1) read -p "输入要允许的端口/服务: " rule && [ -n "$rule" ] && ufw allow "$rule" && ufw status ;; 
            2) read -p "输入要拒绝的端口/服务: " rule && [ -n "$rule" ] && ufw deny "$rule" && ufw status ;; 
            3) read -p "输入要允许的来源IP: " ip && [ -n "$ip" ] && read -p "指定端口(可选): " port && { if [ -n "$port" ]; then ufw allow from "$ip" to any port "$port"; else ufw allow from "$ip"; fi; ufw status; } ;; 
            4) read -p "输入要拒绝的来源IP: " ip && [ -n "$ip" ] && ufw deny from "$ip" && ufw status ;; 
            5) ufw status numbered && read -p "输入要删除的规则编号: " num && [[ "$num" =~ ^[0-9]+$ ]] && yes | ufw delete "$num" && ufw status numbered || echo "无效编号" ;; 
            6) break ;; 
            *) echo "无效选项。" ;; 
        esac
    done
}

# --- 端口转发功能 ---
forward_port_menu() {
    while true; do
        echo -e "\n--- 端口转发配置 ---"
        echo "1. 启用/检查转发所需配置"
        echo "2. 添加一条端口转发规则"
        echo "3. 列出已保存的转发规则"
        echo "4. 删除一条转发规则"
        echo "5. 将所有保存的规则应用到UFW"
        echo "6. 返回主菜单"
        read -p "请选择 [1-6]: " choice
        case $choice in
            1) enable_forwarding_prerequisites ;; 
            2) add_forward_rule ;; 
            3) list_forward_rules ;; 
            4) remove_forward_rule ;; 
            5) apply_forward_rules ;; 
            6) break ;; 
            *) echo "无效选项。" ;; 
        esac
    done
}

enable_forwarding_prerequisites() {
    echo "1. 检查并配置 /etc/sysctl.conf..."
    if grep -q "^#\?net.ipv4.ip_forward=1" /etc/sysctl.conf; then
        sed -i 's/^#\?net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
        echo "  - net.ipv4.ip_forward 已设置为 1"
    else
        echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
        echo "  - 已添加 net.ipv4.ip_forward=1"
    fi
    sysctl -p > /dev/null
    
    echo "2. 检查并配置 /etc/default/ufw..."
    if grep -q "^DEFAULT_FORWARD_POLICY=" /etc/default/ufw; then
        sed -i 's/^DEFAULT_FORWARD_POLICY=.*/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
        echo "  - DEFAULT_FORWARD_POLICY 已设置为 ACCEPT"
    else
        echo 'DEFAULT_FORWARD_POLICY="ACCEPT"' >> /etc/default/ufw
        echo "  - 已添加 DEFAULT_FORWARD_POLICY=\"ACCEPT\""
    fi
    echo "前提配置完成。建议在应用规则后重载UFW。"
}

add_forward_rule() {
    echo "请输入端口转发规则信息:"
    read -p "接收流量的网卡 (例如 eth0, 或留空使用默认的 any): " iface
    read -p "外部端口 (例如 8080): " ext_port
    read -p "目标内网IP (例如 192.168.1.100): " int_ip
    read -p "目标内网端口 (例如 80): " int_port
    read -p "协议 (tcp/udp): " proto

    if [[ -z "$ext_port" || -z "$int_ip" || -z "$int_port" || -z "$proto" ]]; then
        echo "错误：所有字段都不能为空。"
        return
    fi
    iface=${iface:-any} # 如果为空则设为 any
    
    touch $FORWARD_RULES_CONF
    echo "$iface,$ext_port,$int_ip,$int_port,$proto" >> $FORWARD_RULES_CONF
    echo "规则已保存到 $FORWARD_RULES_CONF。请记得选择 '应用规则' 使其生效。'"
}

list_forward_rules() {
    if [ ! -f "$FORWARD_RULES_CONF" ] || ! -s "$FORWARD_RULES_CONF" ] ; then
        echo "没有已保存的转发规则。"
        return
    fi
    echo "--- 已保存的转发规则 (网卡,外网端口,内网IP,内网端口,协议) ---"
    cat -n "$FORWARD_RULES_CONF"
    echo "----------------------------------------------------------------"
}

remove_forward_rule() {
    list_forward_rules
    if [ ! -f "$FORWARD_RULES_CONF" ]; then return; fi
    read -p "请输入要删除的规则编号: " num
    if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -le $(cat $FORWARD_RULES_CONF | wc -l) ]; then
        sed -i "${num}d" "$FORWARD_RULES_CONF"
        echo "规则 #$num 已删除。"
    else
        echo "无效的编号。"
    fi
}

apply_forward_rules() {
    echo "这将重写 /etc/ufw/before.rules 中的 NAT 规则，是否继续? (y/n)"
    read -p "> " confirm
    if [[ "$confirm" != "y" ]]; then echo "操作已取消。"; return; fi

    local nat_rules=""
    if [ -f "$FORWARD_RULES_CONF" ]; then
        while IFS=, read -r iface ext_port int_ip int_port proto; do
            nat_rules+=" -A PREROUTING -i $iface -p $proto --dport $ext_port -j DNAT --to-destination $int_ip:$int_port\n"
        done < "$FORWARD_RULES_CONF"
    fi

    # 使用 sed 在 # END UFW FORWARD RULES 和 COMMIT 之间插入规则
    # 首先删除旧的规则块
    sed -i '/^# CUSTOM_FORWARD_RULES_START/,/^# CUSTOM_FORWARD_RULES_END/d' /etc/ufw/before.rules
    # 添加新的规则块
    sed -i "/# End required lines/a # CUSTOM_FORWARD_RULES_START\n*nat\n:PREROUTING ACCEPT [0:0]\n$nat_rules\nCOMMIT\n# CUSTOM_FORWARD_RULES_END" /etc/ufw/before.rules

    echo "规则已写入 /etc/ufw/before.rules。"
    read -p "是否立即重载UFW使配置生效? (y/n): " reload_confirm
    if [[ "$reload_confirm" == "y" ]]; then
        ufw reload
        echo "UFW已重载。"
    fi
}


# --- 主菜单循环 ---
while true; do
    echo -e "\n============================="
    echo "      UFW 防火墙管理器"
    echo "============================="
    ufw status | head -n 1
    echo "-----------------------------"
    echo "1. 查看详细状态和规则"
    echo "2. 安装 UFW"
    echo "3. 启用防火墙"
    echo "4. 禁用防火墙"
    echo "5. 添加/更新 SSH 端口规则"
    echo "6. 管理端口和IP规则"
    echo "7. 配置端口转发"
    echo "8. 退出"
    echo "-----------------------------"
    read -p "请输入您的选择 [1-8]: " main_choice

    case $main_choice in
        1) ufw status verbose ;; 
        2) install_ufw ;; 
        3) echo "正在启用防火墙..." && yes | ufw enable && ufw status ;; 
        4) echo "正在禁用防火墙..." && ufw disable && ufw status ;; 
        5) handle_ssh_rule ;; 
        6) manage_other_rules ;; 
        7) forward_port_menu ;; 
        8) echo "再见!"; exit 0 ;; 
        *) echo "无效的选择，请重试。" ;; 
    esac
done
