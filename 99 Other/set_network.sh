#!/bin/bash

# 检查是否以root用户运行
if [ "$EUID" -ne 0 ]; then
  echo "此脚本需要root权限才能运行。请使用 sudo 运行此脚本。"
  exit 1
fi

echo "----------------------------------------"
echo "  主机名和IP地址修改脚本 (使用默认值)"
echo "----------------------------------------"

# 获取所有非回环网卡接口名称
INTERFACES=($(ip -o link show | awk -F': ' '{print $2}' | grep -v "lo" | grep -v "virbr" | grep -v "docker"))

# 检查是否找到网卡
if [ ${#INTERFACES[@]} -eq 0 ]; then
    echo "未找到可用的网卡接口。请手动检查您的网络配置。"
    exit 1
fi

echo "检测到以下网卡接口:"
for i in "${!INTERFACES[@]}"; do
  echo "  $((i+1)). ${INTERFACES[$i]}"
done

# 提示用户选择网卡
read -p "请选择要修改的网卡接口编号 (例如: 1): " CHOICE_NUM

# 验证用户输入
if ! [[ "$CHOICE_NUM" =~ ^[0-9]+$ ]] || [ "$CHOICE_NUM" -lt 1 ] || [ "$CHOICE_NUM" -gt ${#INTERFACES[@]} ]; then
    echo "无效的选择。请重新运行脚本并输入正确的编号。"
    exit 1
fi

# 确定用户选择的网卡
INTERFACE=${INTERFACES[$((CHOICE_NUM-1))]}
echo "您选择了网卡: $INTERFACE"

echo ""

# 获取当前主机名作为默认值
CURRENT_HOSTNAME=$(hostname)
read -p "请输入新的主机名 (默认: $CURRENT_HOSTNAME): " NEW_HOSTNAME
NEW_HOSTNAME="${NEW_HOSTNAME:-$CURRENT_HOSTNAME}" # 如果用户输入为空，使用默认值

# 获取当前IP地址、子网掩码和网关作为默认值
CURRENT_IP=$(ip -4 addr show "$INTERFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
CURRENT_NETMASK_CIDR=$(ip -4 addr show "$INTERFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}/\d+' | awk -F'/' '{print "/"$2}')
CURRENT_GATEWAY=$(ip r | grep default | awk '{print $3}' | head -n 1) # 获取第一个默认网关
CURRENT_DNS_SERVERS=$(grep -P '^nameserver\s+\d+(\.\d+){3}' /etc/resolv.conf | awk '{print $2}' | paste -sd, -)

read -p "请输入新的IP地址 (默认: $CURRENT_IP): " INPUT_IP
NEW_IP="${INPUT_IP:-$CURRENT_IP}"

# 提示用户输入新的子网掩码，并尝试从当前IP获取CIDR转换为点分十进制
CURRENT_NETMASK_DOT="255.255.255.0" # 默认一个常见的子网掩码，以防无法解析
if [ -n "$CURRENT_NETMASK_CIDR" ]; then
    # 简单地将CIDR转换为一个常见的点分十进制掩码，这里只做常见CIDR的转换，不保证完全准确
    case "$CURRENT_NETMASK_CIDR" in
        /32) CURRENT_NETMASK_DOT="255.255.255.255" ;;
        /31) CURRENT_NETMASK_DOT="255.255.255.254" ;;
        /30) CURRENT_NETMASK_DOT="255.255.255.252" ;;
        /29) CURRENT_NETMASK_DOT="255.255.255.248" ;;
        /28) CURRENT_NETMASK_DOT="255.255.255.240" ;;
        /27) CURRENT_NETMASK_DOT="255.255.255.224" ;;
        /26) CURRENT_NETMASK_DOT="255.255.255.192" ;;
        /25) CURRENT_NETMASK_DOT="255.255.255.128" ;;
        /24) CURRENT_NETMASK_DOT="255.255.255.0"   ;;
        /23) CURRENT_NETMASK_DOT="255.255.254.0"   ;;
        /22) CURRENT_NETMASK_DOT="255.255.252.0"   ;;
        /21) CURRENT_NETMASK_DOT="255.255.248.0"   ;;
        /20) CURRENT_NETMASK_DOT="255.255.240.0"   ;;
        /19) CURRENT_NETMASK_DOT="255.255.224.0"   ;;
        /18) CURRENT_NETMASK_DOT="255.255.192.0"   ;;
        /17) CURRENT_NETMASK_DOT="255.255.128.0"   ;;
        /16) CURRENT_NETMASK_DOT="255.255.0.0"     ;;
        # 更多转换可以继续添加
        *) CURRENT_NETMASK_DOT="" ;; # 无法转换，留空
    esac
fi
read -p "请输入新的子网掩码 (默认: $CURRENT_NETMASK_DOT): " INPUT_NETMASK
NEW_NETMASK="${INPUT_NETMASK:-$CURRENT_NETMASK_DOT}"

read -p "请输入新的网关 (默认: $CURRENT_GATEWAY): " INPUT_GATEWAY
NEW_GATEWAY="${INPUT_GATEWAY:-$CURRENT_GATEWAY}"

read -p "请输入DNS服务器 (多个用逗号分隔，默认: $CURRENT_DNS_SERVERS): " INPUT_DNS_SERVERS
NEW_DNS_SERVERS="${INPUT_DNS_SERVERS:-$CURRENT_DNS_SERVERS}"

echo ""
echo "您将要进行的更改:"
echo "  目标网卡: $INTERFACE"
echo "  新主机名: $NEW_HOSTNAME"
echo "  新IP地址: $NEW_IP"
echo "  新子网掩码: $NEW_NETMASK"
echo "  新网关: $NEW_GATEWAY"
if [ -n "$NEW_DNS_SERVERS" ]; then
    echo "  新DNS服务器: $NEW_DNS_SERVERS"
fi
echo ""

read -p "确认修改吗？(y/N): " CONFIRMATION

if [[ "$CONFIRMATION" =~ ^[yY]$ ]]; then
    echo "正在应用更改..."

    # 1. 修改主机名
    echo "正在修改主机名..."
    if [ "$NEW_HOSTNAME" != "$CURRENT_HOSTNAME" ]; then
        hostnamectl set-hostname "$NEW_HOSTNAME"
        # 修改 /etc/hosts 文件，将旧主机名映射更新为新主机名
        if grep -q "127.0.1.1" /etc/hosts; then
            sudo sed -i "/127.0.1.1/s/$CURRENT_HOSTNAME/$NEW_HOSTNAME/" /etc/hosts
        fi
        echo "主机名已修改为: $NEW_HOSTNAME"
    else
        echo "主机名未更改。"
    fi


    # 2. 修改IP地址配置
    echo "正在修改IP地址配置..."

    # 将子网掩码转换为CIDR前缀 (例如 255.255.255.0 -> /24)
    # 使用 Python 来更准确地计算 CIDR
    if command -v python3 &> /dev/null; then
        CIDR_PREFIX=$(python3 -c "
import ipaddress
try:
    netmask = ipaddress.IPv4Address('$NEW_NETMASK')
    print(f'/{ipaddress.IPv4Network(f'0.0.0.0/{netmask}').prefixlen}')
except ipaddress.AddressValueError:
    print('')
" 2>/dev/null)
    elif command -v python &> /dev/null; then # 尝试 python2
        CIDR_PREFIX=$(python -c "
import ipaddress
try:
    netmask = ipaddress.IPv4Address('$NEW_NETMASK')
    print(f'/{ipaddress.IPv4Network(f'0.0.0.0/{netmask}').prefixlen}')
except ipaddress.AddressValueError:
    print('')
" 2>/dev/null)
    else
        echo "警告: 未找到 Python，无法准确计算子网掩码对应的CIDR前缀。"
        # 回退到简单的case判断，或者保持为空
        case "$NEW_NETMASK" in
            255.255.255.255) CIDR_PREFIX="/32" ;; 255.255.255.254) CIDR_PREFIX="/31" ;;
            255.255.255.252) CIDR_PREFIX="/30" ;; 255.255.255.248) CIDR_PREFIX="/29" ;;
            255.255.255.240) CIDR_PREFIX="/28" ;; 255.255.255.224) CIDR_PREFIX="/27" ;;
            255.255.255.192) CIDR_PREFIX="/26" ;; 255.255.255.128) CIDR_PREFIX="/25" ;;
            255.255.255.0)   CIDR_PREFIX="/24" ;; 255.255.254.0)   CIDR_PREFIX="/23" ;;
            255.255.252.0)   CIDR_PREFIX="/22" ;; 255.255.248.0)   CIDR_PREFIX="/21" ;;
            255.255.240.0)   CIDR_PREFIX="/20" ;; 255.255.224.0)   CIDR_PREFIX="/19" ;;
            255.255.192.0)   CIDR_PREFIX="/18" ;; 255.255.128.0)   CIDR_PREFIX="/17" ;;
            255.255.0.0)     CIDR_PREFIX="/16" ;; 255.254.0.0)     CIDR_PREFIX="/15" ;;
            255.252.0.0)     CIDR_PREFIX="/14" ;; 255.248.0.0)     CIDR_PREFIX="/13" ;;
            255.240.0.0)     CIDR_PREFIX="/12" ;; 255.224.0.0)     CIDR_PREFIX="/11" ;;
            255.192.0.0)     CIDR_PREFIX="/10" ;; 255.128.0.0)     CIDR_PREFIX="/9" ;;
            255.0.0.0)       CIDR_PREFIX="/8" ;;
            *) CIDR_PREFIX="" ;;
        esac
    fi

    if [ -z "$CIDR_PREFIX" ]; then
        echo "警告: 无法将子网掩码 ($NEW_NETMASK) 转换为CIDR格式。这可能会影响某些网络配置工具的正常工作。"
        echo "请确保您输入的子网掩码是有效的，并且常见的子网掩码。将尝试使用IP地址不带CIDR进行配置。"
        NEW_IP_CIDR="$NEW_IP" # 无法转换，直接使用IP地址
    else
        NEW_IP_CIDR="${NEW_IP}${CIDR_PREFIX}"
    fi

    NETWORK_CONFIG_SUCCESS=false

    # --- 尝试 Netplan 配置 ---
    if command -v netplan &> /dev/null && [ -d "/etc/netplan" ]; then
        echo "检测到 Netplan。尝试通过 Netplan 配置网络..."
        NETPLAN_CONFIG_FILE=$(find /etc/netplan -maxdepth 1 -name "*.yaml" -print | sort -n | head -n 1)
        if [ -z "$NETPLAN_CONFIG_FILE" ]; then # 如果没找到，创建一个默认的
            NETPLAN_CONFIG_FILE="/etc/netplan/01-config.yaml"
            echo "未找到现有 Netplan 配置文件，将创建新的: $NETPLAN_CONFIG_FILE"
        fi

        # 备份原始文件
        sudo cp "$NETPLAN_CONFIG_FILE" "$NETPLAN_CONFIG_FILE.bak.$(date +%Y%m%d%H%M%S)" 2>/dev/null || true # 允许文件不存在时备份失败
        echo "已备份 Netplan 配置 (如果存在) 到 $NETPLAN_CONFIG_FILE.bak.*"

        # 生成新的 Netplan 配置内容
        NETPLAN_CONTENT="network:\n"
        NETPLAN_CONTENT+="  version: 2\n"
        NETPLAN_CONTENT+="  renderer: networkd\n" # 默认使用 networkd，可以根据系统实际情况改为 NetworkManager
        NETPLAN_CONTENT+="  ethernets:\n"
        NETPLAN_CONTENT+="    $INTERFACE:\n"
        NETPLAN_CONTENT+="      dhcp4: no\n"
        NETPLAN_CONTENT+="      addresses: [$NEW_IP_CIDR]\n"
        NETPLAN_CONTENT+="      routes:\n"
        NETPLAN_CONTENT+="        - to: default\n"
        NETPLAN_CONTENT+="          via: $NEW_GATEWAY\n"
        
        if [ -n "$NEW_DNS_SERVERS" ]; then
            DNS_YAML_LIST=$(echo "$NEW_DNS_SERVERS" | sed 's/,/","/g' | sed 's/^/"/;s/$/"/')
            NETPLAN_CONTENT+="      nameservers:\n"
            NETPLAN_CONTENT+="        addresses: [$DNS_YAML_LIST]\n"
        fi

        echo -e "$NETPLAN_CONTENT" | sudo tee "$NETPLAN_CONFIG_FILE" > /dev/null

        echo "Netplan 配置已更新到 $NETPLAN_CONFIG_FILE"
        echo "正在应用 Netplan 配置..."
        if sudo netplan apply; then
            echo "Netplan 配置应用成功。"
            NETWORK_CONFIG_SUCCESS=true
        else
            echo "Netplan 配置应用失败。请检查 $NETPLAN_CONFIG_FILE 文件或手动排查。"
            # 尝试回滚 Netplan 配置
            if [ -f "$NETPLAN_CONFIG_FILE.bak.$(date +%Y%m%d%H%M%S)" ]; then # 只有当备份文件存在时才回滚
                sudo cp "$NETPLAN_CONFIG_FILE.bak.$(date +%Y%m%d%H%M%S)" "$NETPLAN_CONFIG_FILE"
                echo "已尝试回滚 Netplan 配置。"
            fi
        fi
    fi

    # --- 尝试 NetworkManager 配置 ---
    if ! $NETWORK_CONFIG_SUCCESS && command -v nmcli &> /dev/null && systemctl is-active --quiet NetworkManager; then
        echo "未通过 Netplan 配置成功或 Netplan 不存在。检测到 NetworkManager。尝试通过 nmcli 配置网络..."
        
        # 确保连接存在，如果不存在则创建一个
        if ! sudo nmcli connection show "$INTERFACE" &>/dev/null; then
            echo "NetworkManager 中未找到连接 $INTERFACE，尝试创建新连接..."
            sudo nmcli connection add type ethernet ifname "$INTERFACE" con-name "$INTERFACE"
        fi

        # 备份 NetworkManager 连接配置文件 (如果存在)
        NM_CONN_FILE="/etc/NetworkManager/system-connections/${INTERFACE}.nmconnection"
        if [ -f "$NM_CONN_FILE" ]; then
            sudo cp "$NM_CONN_FILE" "$NM_CONN_FILE.bak.$(date +%Y%m%d%H%M%S)"
            echo "已备份 NetworkManager 连接文件: $NM_CONN_FILE"
        fi

        NM_CMD="sudo nmcli connection modify $INTERFACE ipv4.method manual ipv4.addresses ${NEW_IP_CIDR} ipv4.gateway ${NEW_GATEWAY}"
        if [ -n "$NEW_DNS_SERVERS" ]; then
            NM_CMD="$NM_CMD ipv4.dns \"${NEW_DNS_SERVERS}\""
        fi
        NM_CMD="$NM_CMD connection.autoconnect yes" # 确保开机自启动
        
        echo "执行命令: $NM_CMD"
        if eval "$NM_CMD"; then
            echo "NetworkManager 配置已更新。"
            echo "正在重新激活网卡 $INTERFACE..."
            if sudo nmcli connection up "$INTERFACE"; then
                echo "网卡 $INTERFACE 已重新激活。"
                NETWORK_CONFIG_SUCCESS=true
            else
                echo "NetworkManager 重新激活网卡失败。请手动检查 nmcli status 或 journalctl -xe。"
            fi
        else
            echo "NetworkManager 配置失败。请检查 nmcli 命令输出。"
        fi
    fi

    # --- 尝试传统的 Debian/Ubuntu 配置 (如果前面都失败) ---
    if ! $NETWORK_CONFIG_SUCCESS && [ -f "/etc/network/interfaces" ]; then
        echo "未通过 Netplan 或 NetworkManager 配置成功。尝试传统的 /etc/network/interfaces 配置..."
        # 备份原始文件
        cp /etc/network/interfaces /etc/network/interfaces.bak.$(date +%Y%m%d%H%M%S)
        echo "已备份 /etc/network/interfaces 到 /etc/network/interfaces.bak.$(date +%Y%m%d%H%M%S)"

        # 确保网卡配置为静态
        if ! grep -q "iface $INTERFACE inet static" /etc/network/interfaces; then
            echo "auto $INTERFACE" | sudo tee -a /etc/network/interfaces > /dev/null
            echo "iface $INTERFACE inet static" | sudo tee -a /etc/network/interfaces > /dev/null
        fi

        # 使用 awk 更精确地替换/添加配置，避免sed的复杂性
        # 构建新的配置块
        NEW_CONFIG_BLOCK="iface $INTERFACE inet static\n"
        NEW_CONFIG_BLOCK+="        address $NEW_IP\n"
        NEW_CONFIG_BLOCK+="        netmask $NEW_NETMASK\n"
        NEW_CONFIG_BLOCK+="        gateway $NEW_GATEWAY\n"
        if [ -n "$NEW_DNS_SERVERS" ]; then
            # 将逗号分隔的DNS服务器转换为空格分隔
            DNS_SPACE_SEPARATED=$(echo "$NEW_DNS_SERVERS" | sed 's/,/ /g')
            NEW_CONFIG_BLOCK+="        dns-nameservers $DNS_SPACE_SEPARATED\n"
        fi

        # 替换或添加配置块
        # 首先删除旧的配置块 (如果存在)
        sudo sed -i "/^iface $INTERFACE inet/,/^$/d" /etc/network/interfaces
        # 然后在文件末尾添加新的配置块
        echo -e "$NEW_CONFIG_BLOCK" | sudo tee -a /etc/network/interfaces > /dev/null

        echo "网络配置已更新，位于 /etc/network/interfaces"

        # 重启网络服务
        echo "正在重启网络服务..."
        systemctl restart networking
        NETWORK_CONFIG_SUCCESS=true
    fi
    
    # --- 尝试传统的 CentOS/RHEL 配置 (如果前面都失败) ---
    if ! $NETWORK_CONFIG_SUCCESS && [ -f "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE" ]; then
        echo "未通过 Netplan、NetworkManager 或 /etc/network/interfaces 配置成功。尝试传统的 /etc/sysconfig/network-scripts/ifcfg-$INTERFACE 配置..."
        # 备份原始文件
        cp "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE" "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE.bak.$(date +%Y%m%d%H%M%S)"
        echo "已备份 /etc/sysconfig/network-scripts/ifcfg-$INTERFACE 到 /etc/sysconfig/network-scripts/ifcfg-$INTERFACE.bak.$(date +%Y%m%d%H%M%S)"

        # 使用 sed 修改或添加行
        sudo sed -i "/^BOOTPROTO=/c\BOOTPROTO=static" "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE"
        sudo sed -i "/^IPADDR=/c\IPADDR=$NEW_IP" "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE"
        sudo sed -i "/^NETMASK=/c\NETMASK=$NEW_NETMASK" "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE"
        sudo sed -i "/^GATEWAY=/c\GATEWAY=$NEW_GATEWAY" "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE"
        
        # 添加缺失的行
        if ! grep -q "^BOOTPROTO=" "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE"; then echo "BOOTPROTO=static" | sudo tee -a "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE" > /dev/null; fi
        if ! grep -q "^IPADDR=" "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE"; then echo "IPADDR=$NEW_IP" | sudo tee -a "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE" > /dev/null; fi
        if ! grep -q "^NETMASK=" "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE"; then echo "NETMASK=$NEW_NETMASK" | sudo tee -a "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE" > /dev/null; fi
        if ! grep -q "^GATEWAY=" "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE"; then echo "GATEWAY=$NEW_GATEWAY" | sudo tee -a "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE" > /dev/null; fi
        if ! grep -q "^ONBOOT=" "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE"; then echo "ONBOOT=yes" | sudo tee -a "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE" > /dev/null; fi # 确保开机启动

        if [ -n "$NEW_DNS_SERVERS" ]; then
            # 将逗号分隔的DNS服务器转换为空格分隔
            DNS_SPACE_SEPARATED=$(echo "$NEW_DNS_SERVERS" | sed 's/,/ /g')
            sudo sed -i "/^GATEWAY=/a\DNS=\"$DNS_SPACE_SEPARATED\"" "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE"
        fi

        echo "网络配置已更新，位于 /etc/sysconfig/network-scripts/ifcfg-$INTERFACE"

        # 重启网络服务
        echo "正在重启网络服务..."
        systemctl restart network
        NETWORK_CONFIG_SUCCESS=true
    fi

    # 如果所有尝试都失败
    if ! $NETWORK_CONFIG_SUCCESS; then
        echo "未能通过任何已知方式自动配置网络。"
        echo "请根据您的Linux发行版和网络管理工具（如Netplan, NetworkManager）手动配置网络。"
        echo "主机名已修改，但IP地址未更改。"
    fi

    echo ""
    echo "主机名和IP地址修改完成。请验证网络连接。"
    echo "当前主机名: $(hostname)"
    # 尝试获取新IP，但如果配置失败，可能仍显示旧IP
    echo "当前IP地址: $(ip -4 addr show $INTERFACE | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || echo '无法获取新IP地址，请手动验证')"

else
    echo "操作已取消。"
fi

echo "----------------------------------------"
