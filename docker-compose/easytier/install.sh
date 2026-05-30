#!/bin/bash

# 确保脚本在遇到错误时立即退出
set -e

echo "--- Easytier Docker 部署脚本 ---"

# 检查 docker 和 docker-compose 是否安装
if ! command -v docker &> /dev/null
then
    echo "错误: docker 未安装。请先安装 docker。"
    exit 1
fi

if ! command -v docker-compose &> /dev/null
then
    echo "错误: docker-compose 未安装。请先安装 docker-compose。"
    exit 1
fi

# 检查 .env 文件是否存在
if [ -f .env ]; then
    echo ".env 文件已存在，直接使用现有配置启动 Docker Compose。"
    echo ""
    docker-compose up -d
    echo ""
    echo "Easytier 服务已在后台启动！"
    echo "你可以使用 'docker-compose logs -f easytier' 查看日志。"
    exit 0
fi

# 如果 .env 文件不存在，进入交互模式
echo ".env 文件未找到，将进入交互式配置模式。"
echo ""

# 引导用户输入必填项
read -p "请输入 Easytier 网络名称: " ET_NETWORK_NAME
read -p "请输入 Easytier 网络密钥: " ET_NETWORK_SECRET

# 引导用户输入可选配置项，并提供默认值
read -p "请输入 Easytier IPv4 地址 (默认为 10.144.144.1): " ET_IPV4
if [ -z "$ET_IPV4" ]; then
    ET_IPV4="10.144.144.1"
fi

read -p "请输入 Easytier 网络端口: (例如: 11010)" ET_LISTENERS
read -p "请输入 Easytier 对等节点 (例如: udp://127.0.0.1:11010 留空则无): " ET_PEERS
read -p "请输入 Easytier 主机名 (留空则无): " ET_HOSTNAME
read -p "是否接受 DNS (true/false, 默认为 true): " ET_ACCEPT_DNS
if [ -z "$ET_ACCEPT_DNS" ]; then
    ET_ACCEPT_DNS="true"
fi

read -p "是否启用 QUIC 代理 (true/false, 默认为 true): " ET_ENABLE_QUIC_PROXY
if [ -z "$ET_ENABLE_QUIC_PROXY" ]; then
    ET_ENABLE_QUIC_PROXY="true"
fi

read -p "是否启用私有模式 (true/false, 默认为 true): " ET_PRIVATE_MODE
if [ -z "$ET_PRIVATE_MODE" ]; then
    ET_PRIVATE_MODE="true"
fi

read -p "请输入外部发现节点地址 (留空则无): " ET_EXTERNAL_NODE
read -p "请输入代理网络 (例如: 10.0.0.0/24->192.168.0.0/24, 留空则无): " ET_PROXY_NETWORKS

echo ""
echo "--- 配置信息预览 ---"
echo "网络名称: $ET_NETWORK_NAME"
echo "网络密钥: $ET_NETWORK_SECRET"
echo "IPv4 地址: $ET_IPV4"
echo "网络端口: $ET_LISTENERS"
echo "对等节点: $ET_PEERS"
echo "主机名: $ET_HOSTNAME"
echo "接受 DNS: $ET_ACCEPT_DNS"
echo "启用 QUIC 代理: $ET_ENABLE_QUIC_PROXY"
echo "私有模式: $ET_PRIVATE_MODE"
echo "外部发现节点: $ET_EXTERNAL_NODE"
echo "代理网络: $ET_PROXY_NETWORKS"
echo ""

# 将非空的环境变量写入 .env 文件
echo "创建 .env 文件..."
echo "# Easytier 环境变量配置" > .env
[ -n "$ET_NETWORK_NAME" ] && echo "ET_NETWORK_NAME=$ET_NETWORK_NAME" >> .env
[ -n "$ET_NETWORK_SECRET" ] && echo "ET_NETWORK_SECRET=$ET_NETWORK_SECRET" >> .env
[ -n "$ET_IPV4" ] && echo "ET_IPV4=$ET_IPV4" >> .env
[ -n "$ET_LISTENERS" ] && echo "ET_LISTENERS=$ET_LISTENERS" >> .env
[ -n "$ET_PEERS" ] && echo "ET_PEERS=$ET_PEERS" >> .env
[ -n "$ET_HOSTNAME" ] && echo "ET_HOSTNAME=$ET_HOSTNAME" >> .env
[ -n "$ET_ACCEPT_DNS" ] && echo "ET_ACCEPT_DNS=$ET_ACCEPT_DNS" >> .env
[ -n "$ET_ENABLE_QUIC_PROXY" ] && echo "ET_ENABLE_QUIC_PROXY=$ET_ENABLE_QUIC_PROXY" >> .env
[ -n "$ET_PRIVATE_MODE" ] && echo "ET_PRIVATE_MODE=$ET_PRIVATE_MODE" >> .env
[ -n "$ET_EXTERNAL_NODE" ] && echo "ET_EXTERNAL_NODE=$ET_EXTERNAL_NODE" >> .env
[ -n "$ET_PROXY_NETWORKS" ] && echo "ET_PROXY_NETWORKS=$ET_PROXY_NETWORKS" >> .env
echo "成功创建 .env 文件。"
echo ""


# 使用 -f 参数指定你的 docker-compose 文件名
echo "启动 docker-compose..."
docker-compose up -d

echo ""
echo "Easytier 服务已在后台启动！"
echo "你可以使用 'docker-compose logs -f easytier' 查看日志。"