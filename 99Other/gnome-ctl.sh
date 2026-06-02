#!/usr/bin/env bash
# gnome-ctl.sh — GNOME 桌面管理脚本 (Debian 13 trixie + GDM3)
# 用法: gnome-ctl.sh {start|stop|restart|status|enable|disable}
#
#   start    - 立即启动 GNOME 桌面 (gdm)，不改变开机默认目标
#   stop     - 立即停止 GNOME 桌面
#   restart  - 重启 gdm
#   status   - 查看当前状态
#   enable   - 设置开机自启 GNOME (graphical.target)
#   disable  - 设置开机不启 GNOME (multi-user.target，纯命令行)
#
# enable/disable 只影响下次开机；start/stop 只影响当前运行。

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SERVICE="gdm"

die()  { echo -e "${RED}错误: $*${NC}" >&2; exit 1; }
info() { echo -e "${GREEN}✔${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*"; }
note() { echo -e "${CYAN}ℹ${NC} $*"; }

check_root() {
    [[ $EUID -eq 0 ]] || die "需要 root 权限，请用 sudo 运行"
}

# 获取 GDM 运行状态
gdm_active() {
    systemctl is-active --quiet "$SERVICE" 2>/dev/null && echo "运行中" || echo "已停止"
}

# 获取开机默认目标
boot_target() {
    systemctl get-default 2>/dev/null
}

# 人类可读的目标名
target_label() {
    case "$1" in
        graphical.target)   echo "图形界面 (graphical.target)" ;;
        multi-user.target)  echo "命令行 (multi-user.target)" ;;
        *)                  echo "$1" ;;
    esac
}

cmd_status() {
    local target
    target=$(boot_target)
    echo ""
    echo "┌─────────────────────────────────────────┐"
    echo "│          GNOME 桌面状态                  │"
    echo "├─────────────────────────────────────────┤"
    printf "│  GDM 服务:      %-24s│\n" "$(gdm_active)"
    printf "│  开机默认:      %-24s│\n" "$(target_label "$target")"
    echo "└─────────────────────────────────────────┘"
    echo ""
    if [[ "$target" == "graphical.target" ]]; then
        note "下次开机会自动进入 GNOME 图形界面"
    else
        note "下次开机会进入纯命令行 (multi-user)"
    fi
}

cmd_start() {
    check_root
    if systemctl is-active --quiet "$SERVICE" 2>/dev/null; then
        warn "GDM 已在运行中，无需重复启动"
        return 0
    fi
    echo "正在启动 GNOME 桌面..."
    systemctl start "$SERVICE"
    sleep 1
    if systemctl is-active --quiet "$SERVICE"; then
        info "GNOME 桌面已启动"
        note "开机默认目标未改变: $(target_label "$(boot_target)")"
    else
        die "GDM 启动失败，用 systemctl status $SERVICE 查看详情"
    fi
}

cmd_stop() {
    check_root
    if ! systemctl is-active --quiet "$SERVICE" 2>/dev/null; then
        warn "GDM 已经是停止状态"
        return 0
    fi
    echo "正在停止 GNOME 桌面 (所有图形会话将断开)..."
    systemctl stop "$SERVICE"
    info "GNOME 桌面已停止"
    note "开机默认目标未改变: $(target_label "$(boot_target)")"
}

cmd_restart() {
    check_root
    echo "正在重启 GDM..."
    systemctl restart "$SERVICE"
    sleep 1
    if systemctl is-active --quiet "$SERVICE"; then
        info "GDM 已重启"
    else
        die "GDM 重启失败"
    fi
}

cmd_enable() {
    check_root
    echo "设置开机自启 GNOME 桌面..."
    systemctl set-default graphical.target
    info "已设置 graphical.target 为开机默认目标"
    if ! systemctl is-active --quiet "$SERVICE" 2>/dev/null; then
        warn "GDM 当前未运行"
        read -rp "是否现在也启动 GNOME？[y/N] " ans
        if [[ "${ans,,}" == "y" ]]; then
            cmd_start
        fi
    fi
}

cmd_disable() {
    check_root
    echo "设置开机不启动 GNOME 桌面..."
    systemctl set-default multi-user.target
    info "已设置 multi-user.target 为开机默认目标"
    if systemctl is-active --quiet "$SERVICE" 2>/dev/null; then
        warn "GDM 当前仍在运行"
        read -rp "是否现在也停止 GNOME？[y/N] " ans
        if [[ "${ans,,}" == "y" ]]; then
            cmd_stop
        fi
    fi
    note "下次开机将进入纯命令行，需要时用 '$0 start' 手动启动"
}

usage() {
    echo "用法: $(basename "$0") {start|stop|restart|status|enable|disable}"
    echo ""
    echo "  start    立即启动 GNOME 桌面"
    echo "  stop     立即停止 GNOME 桌面"
    echo "  restart  重启 GDM"
    echo "  status   查看当前状态"
    echo "  enable   设置开机自启 GNOME"
    echo "  disable  设置开机不启 GNOME (纯命令行)"
    exit 1
}

[[ $# -ge 1 ]] || { cmd_status; exit 0; }

case "${1,,}" in
    start)   cmd_start   ;;
    stop)    cmd_stop    ;;
    restart) cmd_restart ;;
    status)  cmd_status  ;;
    enable)  cmd_enable  ;;
    disable) cmd_disable ;;
    *)       usage       ;;
esac
