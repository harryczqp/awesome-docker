<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# 00Tools

## Purpose
A collection of standalone utility scripts for Docker and Linux system administration. This directory houses small, focused tools that simplify common operational tasks such as Docker volume backup/restore, Git repository metadata management, OpenWrt router auto-reboot, and rclone installation with systemd service management.

## Key Files
| File | Description |
|------|-------------|
| `README.md` | Index listing all tools with brief descriptions (in Chinese). |

## Subdirectories
| Directory | Purpose |
|-----------|---------|
| `auto-reboot-router/` | OpenWrt router smart reboot and network recovery scripts (see `auto-reboot-router/AGENTS.md`). |
| `docker-volume-backup/` | Python tool for Docker volume backup, restore, and cleanup (see `docker-volume-backup/AGENTS.md`). |
| `git-manager/` | Python tool for scanning and restoring Git repository metadata across nested directories (see `git-manager/AGENTS.md`). |
| `rclone-installer/` | Interactive Bash script for installing rclone and managing systemd mount services (see `rclone-installer/AGENTS.md`). |

## For AI Agents

### Working In This Directory
- Each subdirectory is an independent tool with its own scripts and documentation.
- When modifying a tool, update its subdirectory `AGENTS.md` and the parent `README.md` if the tool listing changes.
- Scripts are written in a mix of Python 3 and Bash; match the existing language and style of the target tool.

### Testing Requirements
- Python scripts: run with `python script.py --help` or the documented CLI commands.
- Bash scripts: test on a Linux environment; some scripts require `sudo` or root privileges.
- OpenWrt scripts (`auto-reboot-router`) require an actual OpenWrt device or emulator for full testing.

### Common Patterns
- CLI-driven tools with subcommand or interactive menu interfaces.
- Chinese-language comments and output strings are common.
- Environment variables are used for configuration where applicable.
- `subprocess.run()` is the preferred pattern in Python for shelling out.

## Dependencies

### Internal
- None (each tool is self-contained).

### External
- Python 3 (for `docker-volume-backup`, `git-manager`).
- Docker Engine (for `docker-volume-backup`).
- Bash / sh (for `auto-reboot-router`, `rclone-installer`).
- `curl`, `systemctl`, `crontab` (for `rclone-installer`, `auto-reboot-router`).

<!-- MANUAL: -->
