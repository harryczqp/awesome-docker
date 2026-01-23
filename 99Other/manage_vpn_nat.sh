#!/bin/bash

# =================配置区域=================
SERVICE_NAME="custom-vpn-nat"
SCRIPT_PATH="/usr/local/bin/custom-vpn-nat.sh"
SERVICE_PATH="/etc/systemd/system/${SERVICE_NAME}.service"
# =========================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# 检查 root 权限
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}错误: 必须使用 sudo 运行此脚本。${NC}"
   exit 1
fi

# ================= 功能函数 =================

# 1. 安装与配置功能
function install_service() {
    echo -e "\n${CYAN}>>> 开始配置 VPN 转发与 NAT...${NC}"

    # --- 步骤 1: 选择网卡 ---
    echo -e "\n${YELLOW}[Step 1] 请选择 VPN 出口网卡:${NC}"
    ip -o link show | awk -F': ' '{print $2}' | grep -v "lo" | sed 's/^/  - /'
    read -p "> 请输入网卡名称 (如 tun0): " VPN_IFACE

    if ! ip link show "$VPN_IFACE" > /dev/null 2>&1; then
        echo -e "${RED}错误: 网卡 $VPN_IFACE 不存在。${NC}"
        return
    fi

    # --- 步骤 2: 输入网段 ---
    echo -e "\n${YELLOW}[Step 2] 请输入内网网段 (空格分隔):${NC}"
    echo "示例: 10.0.1.0/24 10.0.2.0/24"
    read -p "> " SUBNETS_INPUT
    
    if [ -z "$SUBNETS_INPUT" ]; then
        echo -e "${RED}错误: 网段不能为空。${NC}"
        return
    fi

    # --- 步骤 3: 生成执行脚本 ---
    echo -e "\n${YELLOW}[Step 3] 正在生成控制脚本 ($SCRIPT_PATH)...${NC}"
    
    # 注意：这里使用 EOF 生成真正的逻辑脚本
    # 所有的 \$ 都会被转义，保留给新脚本使用；而 $VPN_IFACE 等变量会被当前替换
    cat > "$SCRIPT_PATH" <<EOF
#!/bin/bash

VPN_IFACE="$VPN_IFACE"
SUBNETS=($SUBNETS_INPUT)

start() {
    echo "Starting VPN NAT rules..."
    # 开启转发
    sysctl -w net.ipv4.ip_forward=1 >> /dev/null

    # 1. 允许 VPN 回流 (Inbound)
    iptables -A FORWARD -i \$VPN_IFACE -j ACCEPT

    # 2. 循环处理每个网段
    for subnet in "\${SUBNETS[@]}"; do
        # 转发 (Outbound)
        iptables -A FORWARD -s \$subnet -o \$VPN_IFACE -j ACCEPT
        # NAT (Masquerade)
        iptables -t nat -A POSTROUTING -s \$subnet -o \$VPN_IFACE -j MASQUERADE
    done
}

stop() {
    echo "Stopping and cleaning VPN NAT rules..."
    # 注意：这里使用 -D 删除规则，确保不影响其他无关配置
    
    # 1. 删除 VPN 回流规则
    iptables -D FORWARD -i \$VPN_IFACE -j ACCEPT 2>/dev/null

    # 2. 循环删除每个网段的规则
    for subnet in "\${SUBNETS[@]}"; do
        iptables -D FORWARD -s \$subnet -o \$VPN_IFACE -j ACCEPT 2>/dev/null
        iptables -t nat -D POSTROUTING -s \$subnet -o \$VPN_IFACE -j MASQUERADE 2>/dev/null
    done
}

case "\$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    *)
        echo "Usage: \$0 {start|stop}"
        exit 1
esac
EOF

    chmod +x "$SCRIPT_PATH"
    echo -e "${GREEN}√ 控制脚本已生成。${NC}"

    # --- 步骤 4: 生成 Systemd 服务文件 ---
    echo -e "\n${YELLOW}[Step 4] 正在配置 Systemd 服务 ($SERVICE_PATH)...${NC}"

    cat > "$SERVICE_PATH" <<EOF
[Unit]
Description=Auto Setup VPN NAT & Forwarding Rules
After=network.target

[Service]
Type=oneshot
ExecStart=$SCRIPT_PATH start
ExecStop=$SCRIPT_PATH stop
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

    # --- 步骤 5: 启用并启动 ---
    echo -e "\n${YELLOW}[Step 5] 启用并启动服务...${NC}"
    systemctl daemon-reload
    systemctl enable "$SERVICE_NAME"
    systemctl start "$SERVICE_NAME"

    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo -e "${GREEN}SUCCESS! 配置成功。${NC}"
        echo -e "规则已应用，且已设置为开机自启。"
        echo -e "你可以通过 'systemctl status $SERVICE_NAME' 查看状态。"
    else
        echo -e "${RED}警告: 服务启动似乎失败了，请检查日志。${NC}"
    fi
}

# 2. 卸载与清理功能
function remove_service() {
    echo -e "\n${CYAN}>>> 准备移除 VPN 转发与 NAT 配置...${NC}"
    
    if [ ! -f "$SERVICE_PATH" ]; then
        echo -e "${RED}错误: 未找到该服务的配置文件，可能尚未安装。${NC}"
        return
    fi

    echo -e "${YELLOW}正在停止服务并清理 iptables 规则...${NC}"
    # 这一步非常关键：它会调用脚本中的 stop() 函数，执行 iptables -D 删除规则
    systemctl stop "$SERVICE_NAME"
    
    echo -e "${YELLOW}正在禁用开机自启...${NC}"
    systemctl disable "$SERVICE_NAME" 2>/dev/null

    echo -e "${YELLOW}正在删除配置文件...${NC}"
    rm -f "$SERVICE_PATH"
    rm -f "$SCRIPT_PATH"

    systemctl daemon-reload
    echo -e "${GREEN}√ 卸载完成！所有相关规则已清除，服务已移除。${NC}"
}

# ================= 主菜单 =================
clear
echo -e "${CYAN}===========================================${NC}"
echo -e "${CYAN}   VPN NAT 转发规则管理器 (Systemd 版)     ${NC}"
echo -e "${CYAN}===========================================${NC}"
echo "1. 配置并启动 (自动开机自启)"
echo "2. 移除配置 (自动清理规则)"
echo "3. 退出"
echo -e "${CYAN}-------------------------------------------${NC}"

read -p "请输入选项 [1-3]: " choice

case $choice in
    1)
        install_service
        ;;
    2)
        remove_service
        ;;
    3)
        echo "拜拜！"
        exit 0
        ;;
    *)
        echo "无效选项。"
        exit 1
        ;;
esac