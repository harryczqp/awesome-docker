#!/bin/sh

# === 配置区域 ===
# 状态文件路径 (存放在非易失存储中，确保重启不丢失)
STATE_FILE="/etc/config/smart_reboot_count"
# 检测的目标IP (建议使用国内稳定DNS或你的网关)
TARGET_IP="223.5.5.5"
# 启动后等待网络就绪的时间 (秒)，避免系统刚启动网卡还没拉起就误判
BOOT_WAIT=60
# ================

# 简单的日志函数
log() {
    logger -t "SmartReboot" "$1"
    # echo "$(date): $1" >> /tmp/smart_reboot.log
    # 注意：频繁写入闪存会影响寿命，但这个脚本只有断网重启时才写，频率很低，是安全的
    echo "$(date): $1" >> /root/smart_reboot_history.log
}

# 检查网络连接
check_network() {
    # 尝试Ping 3次，只要有1次通就认为有网
    ping -c 3 -W 2 $TARGET_IP > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        return 0 # 有网
    else
        return 1 # 无网
    fi
}

# 逻辑模式：CRON触发 (由Cron调用)
if [ "$1" == "cron_trigger" ]; then
    log "Cron计划任务触发。初始化状态并执行第一次重启..."
    echo "1" > $STATE_FILE
    reboot
    exit 0
fi

# 逻辑模式：开机自检 (由 rc.local 调用)
# 只有当状态文件存在时，才说明这是我们脚本触发的重启循环
if [ -f "$STATE_FILE" ]; then
    log "检测到重启状态文件，等待 ${BOOT_WAIT} 秒让系统初始化网络..."
    sleep $BOOT_WAIT

    if check_network; then
        log "网络已恢复正常。删除状态文件，退出循环。"
        rm -f $STATE_FILE
        exit 0
    else
        # 读取当前的尝试次数
        CURRENT_COUNT=$(cat $STATE_FILE)
        log "当前尝试次数: 第 ${CURRENT_COUNT} 次重启后仍无网络。"

        # 计算下一次重启前的等待时间 (单位: 分钟)
        if [ "$CURRENT_COUNT" -eq 1 ]; then
            # 第一次重启后没网 -> 立即重启 (等待0分钟)
            WAIT_MIN=0
        else
            # 基础时间 5分钟
            BASE_WAIT=5
            # 计算指数退避: 5 * 2^(n-2)
            # 由于ash shell数学运算有限，我们用循环计算倍数
            POWER=$((CURRENT_COUNT - 2))
            MULTIPLIER=1
            i=0
            while [ $i -lt $POWER ]; do
                MULTIPLIER=$((MULTIPLIER * 2))
                i=$((i + 1))
            done
            WAIT_MIN=$((BASE_WAIT * MULTIPLIER))
        fi
        
        # 安全上限：防止等待时间过长（例如超过12小时），可设为 720 分钟
        if [ "$WAIT_MIN" -gt 720 ]; then
             WAIT_MIN=720
        fi

        log "计划在 ${WAIT_MIN} 分钟后执行下一次重启..."
        
        # 更新计数器 +1
        NEXT_COUNT=$((CURRENT_COUNT + 1))
        echo "$NEXT_COUNT" > $STATE_FILE

        # 执行等待 (sleep接受秒)
        WAIT_SEC=$((WAIT_MIN * 60))
        sleep $WAIT_SEC

        log "等待结束，正在重启..."
        reboot
    fi
fi