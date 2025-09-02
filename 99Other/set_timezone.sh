#!/bin/sh


# 支持回滚功能
TIMEZONE="Asia/Shanghai"

if [ "$1" = "rollback" ]; then
    # 恢复 /etc/localtime
    if [ -f /etc/localtime.bak ]; then
        mv -f /etc/localtime.bak /etc/localtime
        echo "已恢复 /etc/localtime 到备份状态。"
    else
        echo "/etc/localtime.bak 不存在，无法回滚。"
    fi
    # 恢复 /etc/timezone
    if [ -f /etc/timezone.bak ]; then
        mv -f /etc/timezone.bak /etc/timezone
        echo "已恢复 /etc/timezone 到备份状态。"
    fi
    exit 0
fi

if [ ! -f "/usr/share/zoneinfo/$TIMEZONE" ]; then
    echo "错误: 时区 $TIMEZONE 不存在"
    exit 2
fi

# 备份原有的本地时区设置
if [ -f /etc/localtime ]; then
    cp -f /etc/localtime /etc/localtime.bak
fi

# 备份 /etc/timezone
if [ -f /etc/timezone ]; then
    cp -f /etc/timezone /etc/timezone.bak
fi

# 设置新的时区
ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime

# 写入时区配置文件（如果存在）
if [ -w /etc/timezone ]; then
    echo "$TIMEZONE" > /etc/timezone
fi

echo "时区已设置为 $TIMEZONE"
