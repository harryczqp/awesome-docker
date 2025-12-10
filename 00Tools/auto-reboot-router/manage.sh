#!/bin/sh

# === 配置区域 ===
# 核心脚本名称 (必须和本脚本放在同一目录)
SCRIPT_NAME="smart_reboot.sh"
# Cron 表达式 (默认: 每天凌晨4点重启)
CRON_TIME="0 4 * * *"
# 日志文件路径 (用于卸载时清理)
HISTORY_LOG="/root/smart_reboot_history.log"
STATE_FILE="/etc/config/smart_reboot_count"
# ================

# 动态获取当前目录和绝对路径
SCRIPT_DIR=$(cd $(dirname "$0") && pwd)
TARGET_SCRIPT="${SCRIPT_DIR}/${SCRIPT_NAME}"
RC_FILE="/etc/rc.local"

# 检查核心脚本是否存在
check_script() {
    if [ ! -f "$TARGET_SCRIPT" ]; then
        echo "错误: 未找到核心脚本！"
        echo "路径: $TARGET_SCRIPT"
        echo "请确保 $SCRIPT_NAME 和 manage.sh 在同一个目录下。"
        exit 1
    fi
}

# === 安装函数 ===
install_script() {
    check_script
    echo "----------------------------------------"
    echo "正在安装..."

    # 1. 赋予权限
    chmod +x "$TARGET_SCRIPT"
    echo "[OK] 已赋予脚本执行权限"

    # 2. 配置 rc.local (使用 grep -F 固定字符串匹配，防止特殊字符干扰)
    if grep -Fq "$TARGET_SCRIPT" "$RC_FILE"; then
        echo "[SKIP] rc.local 中已存在启动项"
    else
        # 备份
        cp "$RC_FILE" "${RC_FILE}.bak"
        # 插入命令
        sed -i "/exit 0/i $TARGET_SCRIPT &" "$RC_FILE"
        echo "[OK] 已添加到开机自启 (rc.local)"
    fi

    # 3. 配置 Crontab
    CRON_JOB="$CRON_TIME $TARGET_SCRIPT cron_trigger"
    if crontab -l 2>/dev/null | grep -Fq "$TARGET_SCRIPT"; then
        echo "[SKIP] Crontab 中已存在计划任务"
    else
        (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
        echo "[OK] 已添加计划任务: $CRON_JOB"
    fi

    # 4. 重启 cron 服务
    /etc/init.d/cron restart
    echo "----------------------------------------"
    echo "安装成功！脚本路径: $TARGET_SCRIPT"
}

# === 卸载函数 ===
uninstall_script() {
    echo "----------------------------------------"
    echo "正在卸载..."

    # 1. 清理 rc.local
    if grep -Fq "$TARGET_SCRIPT" "$RC_FILE"; then
        # 使用 grep -v 反向选择，把包含脚本路径的行删掉，写入临时文件再覆盖回去
        # 这种方法比 sed 删除带斜杠的路径更稳定
        grep -v -F "$TARGET_SCRIPT" "$RC_FILE" > "${RC_FILE}.tmp" && mv "${RC_FILE}.tmp" "$RC_FILE"
        chmod +x "$RC_FILE"
        echo "[OK] 已从 rc.local 移除启动项"
    else
        echo "[SKIP] rc.local 中未发现启动项"
    fi

    # 2. 清理 Crontab
    if crontab -l 2>/dev/null | grep -Fq "$TARGET_SCRIPT"; then
        crontab -l | grep -v -F "$TARGET_SCRIPT" | crontab -
        echo "[OK] 已移除 Crontab 计划任务"
    else
        echo "[SKIP] Crontab 中未发现计划任务"
    fi

    # 3. 清理状态文件和日志
    if [ -f "$STATE_FILE" ]; then
        rm -f "$STATE_FILE"
        echo "[OK] 已清理状态文件"
    fi
    
    # 询问是否删除历史日志
    if [ -f "$HISTORY_LOG" ]; then
        read -p "发现历史日志文件 ($HISTORY_LOG)，是否删除? (y/n): " del_log
        if [ "$del_log" = "y" ]; then
            rm -f "$HISTORY_LOG"
            echo "[OK] 已删除历史日志"
        else
            echo "[KEEP] 保留历史日志"
        fi
    fi

    # 4. 重启 cron 服务
    /etc/init.d/cron restart
    echo "----------------------------------------"
    echo "卸载完成！核心脚本文件保留，系统配置已还原。"
}

# === 主菜单 ===
clear
echo "========================================"
echo "   OpenWrt 智能重启脚本管理工具"
echo "   脚本路径: $TARGET_SCRIPT"
echo "========================================"
echo " 1. 安装 / 更新 (Install)"
echo " 2. 卸载 / 清理 (Uninstall)"
echo " 0. 退出 (Exit)"
echo "========================================"
read -p "请输入数字 [0-2]: " choice

case $choice in
    1)
        install_script
        ;;
    2)
        uninstall_script
        ;;
    0)
        exit 0
        ;;
    *)
        echo "无效输入，程序退出。"
        exit 1
        ;;
esac