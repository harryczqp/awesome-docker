<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# auto-reboot-router

## Purpose
An OpenWrt router automation tool that combines scheduled reboots (via Cron) with post-boot network self-checks. If the network is down after a reboot, the script enters a retry loop with exponential backoff, persisting retry state across reboots in non-volatile storage. A companion management script provides one-click install/uninstall via `rc.local` and Crontab.

## Key Files
| File | Description |
|------|-------------|
| `smart-reboot.sh` | Core logic script. Handles network detection (ping), exponential backoff wait-time calculation, state persistence, and reboot execution. Designed to be called by both Cron and `rc.local`. |
| `manage.sh` | Interactive management tool. Provides a menu to install (configure `rc.local` + Crontab) or uninstall (clean up all configs, state files, and logs) the smart reboot system. |
| `readme.md` | Full documentation in Chinese, including configuration guide, usage instructions, and a Mermaid flowchart of the reboot logic. |

## For AI Agents

### Working In This Directory
- Both scripts must remain in the same directory; `manage.sh` resolves `smart-reboot.sh` via relative path.
- Configuration variables live at the top of each script (`CRON_TIME` in `manage.sh`; `TARGET_IP`, `BOOT_WAIT`, `STATE_FILE` in `smart-reboot.sh`).
- The scripts target OpenWrt's `ash` shell; avoid Bash-specific syntax.
- State is persisted in `/etc/config/smart_reboot_count`; logs go to `/root/smart_reboot_history.log`.

### Testing Requirements
- Requires an OpenWrt device or emulator; cannot be fully tested on standard Linux.
- Verify `rc.local` and Crontab modifications carefully to avoid breaking router boot.
- Test ping logic with a known-reachable and known-unreachable IP to confirm detection behavior.

### Common Patterns
- `check_network()` uses `ping -c 3 -W 2` against `TARGET_IP`.
- Exponential backoff formula: `wait_min = 5 * 2^(retry_count - 2)` with a cap of 720 minutes.
- `manage.sh` uses `grep -F` for safe fixed-string matching when editing system files.
- Logging is done via `logger -t` (RAM) and `echo >> /root/...` (persistent flash).

## Dependencies

### Internal
- None.

### External
- OpenWrt with `ash` shell.
- `ping`, `logger`, `reboot`, `crontab`, `sed`, `grep`.
- Write access to `/etc/config/`, `/etc/rc.local`, and `/root/`.

<!-- MANUAL: -->
