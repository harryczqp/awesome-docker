<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# rclone-installer

## Purpose
An interactive Bash script for managing rclone installation and systemd mount services on Linux. It can install or uninstall rclone, create systemd services for automatic cloud storage mounts at boot (with optional encrypted config support), delete existing services, and view service logs via `journalctl`.

## Key Files
| File | Description |
|------|-------------|
| `install_rclone.sh` | Main interactive Bash script. Presents a menu with options to install/update rclone, uninstall rclone, create/delete systemd mount services, and view service logs. |
| `README.md` | Chinese-language documentation explaining each menu option, configuration flow, and usage instructions. |

## For AI Agents

### Working In This Directory
- The script is a single-file interactive tool; all functionality is self-contained.
- Service names are auto-generated as `rclone-mount-{escaped_mount_point}.service`.
- Encrypted config support creates a password helper script at `~/.config/rclone/service_pass.sh` with `700` permissions.
- The script uses `select` for interactive menus and `read -p` for prompts.
- `set -e` is active; be careful that new code paths do not unintentionally trigger early exits.

### Testing Requirements
- Requires a Linux system with `systemd`, `sudo`, and `curl`.
- Test in a VM or container; creating systemd services modifies the host system.
- Verify service creation by checking `systemctl status` and `journalctl` after mounting.
- Uninstall tests should confirm binary removal, service cleanup, and optional config directory deletion.

### Common Patterns
- `command -v rclone &> /dev/null` for checking if rclone is installed.
- `sudo bash -c "cat > ..."` for writing systemd service files.
- `systemd-escape --path` for generating valid service names from mount paths.
- `journalctl -u <service>` for log viewing with follow, tail, and no-pager options.
- `getent passwd` for resolving user home directories.

## Dependencies

### Internal
- None.

### External
- Bash.
- `curl` (for downloading rclone install script).
- `sudo` and `systemctl` (for service management).
- `systemd-escape`, `getent`, `fusermount`.
- `rclone` (installed via the script or pre-existing).

<!-- MANUAL: -->
