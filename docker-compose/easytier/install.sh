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
    docker-compose -f docker-compose.yaml up -d
    echo ""
    echo "Easytier 服务已在后台启动！"
    echo "你可以使用 'docker-compose logs -f easytier' 查看日志。"
    exit 0
fi

# 如果 .env 文件不存在，进入交互模式
echo ".env 文件未找到，将进入交互式配置模式。"
echo ""

# 提示用户输入网络名称
read -p "请输入 Easytier 网络名称: " ET_NETWORK_NAME

# 提示用户输入网络密钥
read -p "请输入 Easytier 网络密钥: " ET_NETWORK_SECRET

# 提示用户输入网络IP（如果需要，否则使用默认值）
read -p "请输入 Easytier 网络IP (默认为 10.144.144.1): " ET_NETWORK_IP
if [ -z "$ET_NETWORK_IP" ]; then
    ET_NETWORK_IP="10.144.144.1"
fi

# 提示用户输入网络端口（如果需要，否则使用默认值）
read -p "请输入 Easytier 网络端口 (默认为 21010): " ET_NETWORK_PORT
if [ -z "$ET_NETWORK_PORT" ]; then
    ET_NETWORK_PORT="21010"
fi


echo ""
echo "--- 准备启动 Easytier ---"
echo "网络名称: $ET_NETWORK_NAME"
echo "网络密钥: $ET_NETWORK_SECRET"
echo "网络IP: $ET_NETWORK_IP"
echo "网络端口: $ET_NETWORK_PORT"
echo ""

# 将环境变量写入一个新文件，然后通过 docker-compose 加载
echo "创建 .env 文件..."
echo "ET_NETWORK_NAME=$ET_NETWORK_NAME" > .env
echo "ET_NETWORK_SECRET=$ET_NETWORK_SECRET" >> .env
echo "ET_NETWORK_IP=$ET_NETWORK_IP" >> .env
echo "ET_NETWORK_PORT=$ET_NETWORK_PORT" >> .env
echo "成功创建 .env 文件。"
echo ""

# 使用 -f 参数指定你的 docker-compose 文件名
echo "启动 docker-compose..."
docker-compose -f docker-compose.yaml up -d

echo ""
echo "Easytier 服务已在后台启动！"
echo "你可以使用 'docker-compose logs -f easytier' 查看日志。"