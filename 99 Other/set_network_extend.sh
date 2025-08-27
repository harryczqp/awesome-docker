#!/bin/bash

# 快速开启bbr及fastopen
# 开启路由转发

# 启用 BBR
cat >> /etc/sysctl.conf << EOF
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF

# 启用 TCP Fast Open
echo "net.ipv4.tcp_fastopen=3" >> /etc/sysctl.conf

# 启用 IP 路由转发
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

# 应用更改
sysctl -p

echo "BBR, TCP Fast Open, and IP forwarding have been enabled."