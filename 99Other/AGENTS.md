<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# 99Other

## Purpose
A collection of Linux system administration shell scripts for server hardening, network configuration, firewall management, SSH hardening, VPN/NAT routing, and Docker service deployment. These scripts provide interactive menu-driven tools for configuring Debian/Ubuntu and RHEL/CentOS systems.

## Key Files
| File | Description |
|------|-------------|
| `fail2ban.sh` | Interactive Fail2Ban manager: installs Fail2Ban, configures SSHD jail (2 failed logins in 5 min = 30-day ban via UFW), starts/stops service, views status, and unbans IPs |
| `manage_vpn_nat.sh` | VPN NAT forwarding rule manager with systemd integration: configures iptables FORWARD and MASQUERADE rules for VPN tunnel interfaces, creates a persistent systemd oneshot service |
| `set_configs_ln.sh` | Creates a symbolic link from `/etc/configs` to a user-specified configs directory (defaults to `/mnt/onedrive/configs/`) |
| `set_env.sh` | Stub/TODO for an environment variable management tool (export, compare, import) |
| `set_firewall.sh` | Interactive UFW firewall manager: installs UFW, manages allow/deny rules for ports/IPs, configures SSH port rules, and sets up DNAT port forwarding via `/etc/ufw/before.rules` |
| `set_network.sh` | Interactive network configuration script: changes hostname, IP address, netmask, gateway, and DNS across Netplan, NetworkManager, `/etc/network/interfaces`, and `/etc/sysconfig/network-scripts/` |
| `set_network_extend.sh` | Enables BBR congestion control, TCP Fast Open, and IPv4 IP forwarding by appending to `/etc/sysctl.conf` |
| `set_sshd.sh` | Comprehensive SSH and user management script: changes SSH port, enables RSA key auth (with optional key generation), toggles password/root login, manages users/groups/sudo privileges, and supports config rollback |
| `set_timezone.sh` | Sets system timezone to `Asia/Shanghai` with backup/rollback support for `/etc/localtime` and `/etc/timezone` |
| `xy_update.bak` | Docker deployment script for `haroldli/xiaoya-tvbox`: pulls the specified image tag, prunes old containers/images/volumes, runs the container with port mappings, and prints access URLs |

## For AI Agents

### Working In This Directory
- All scripts require root/sudo privileges and check for it at startup
- Scripts are interactive (menu-driven with `read` prompts) — they are not designed for non-interactive execution
- Many scripts modify system-critical files (`/etc/ssh/sshd_config`, `/etc/ufw/before.rules`, `/etc/sysctl.conf`, network configs); always create backups before changes
- Scripts target both Debian/Ubuntu (`apt-get`, `ufw`, `netplan`) and RHEL/CentOS (`yum`, `/etc/sysconfig/network-scripts`)
- `set_sshd.sh` and `set_firewall.sh` create backups automatically before modifying configs
- `xy_update.bak` is a backup file; the active version may live elsewhere

### Testing Requirements
- Test in a VM or container; these scripts modify live system configuration
- Verify SSH connectivity before and after running `set_sshd.sh` (risk of lockout)
- For `set_network.sh`, ensure a console/serial connection is available in case network config breaks
- For `manage_vpn_nat.sh`, verify the VPN interface (`tun0`, etc.) exists before running
- Run `sshd -t` to validate SSH config syntax after any `set_sshd.sh` changes

### Common Patterns
- Root privilege check: `[ "$(id -u)" -ne 0 ]` or `[[ $EUID -ne 0 ]]`
- Backup before modify: `cp "$file" "$file.bak.$(date +%Y%m%d%H%M%S)"`
- Package manager detection: `command -v apt-get` vs `command -v yum`
- Service management via `systemctl` with fallback awareness
- Config file editing via `sed -i` with comment-aware pattern matching
- Heredocs (`cat > file <<EOF`) for generating multi-line config files

## Dependencies

### Internal
- `../AGENTS.md` — parent project documentation
- Scripts reference each other's configurations (e.g., `set_firewall.sh` reads SSH port from `/etc/ssh/sshd_config`)

### External
- `fail2ban`, `ufw`, `iptables` — firewall and intrusion prevention
- `systemctl`/`service` — service management
- `ssh-keygen`, `sshd` — SSH key generation and server
- `ip`, `nmcli`, `netplan` — network management tools
- `python3` (optional) — used by `set_network.sh` for CIDR netmask conversion
- `docker` — used by `xy_update.bak` for container deployment

<!-- MANUAL: -->
