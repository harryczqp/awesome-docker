<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# easytier

## Purpose
EasyTier is a peer-to-peer VPN solution that creates secure mesh networks between nodes. It runs in host network mode with NET_ADMIN and NET_RAW capabilities, using a TUN device for virtual network interfaces. Configuration is loaded from an external `.env` file at `/etc/configs/easytier/.env`.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | Docker Compose configuration for easytier |
| `install.sh` | Installation script for easytier setup |

## For AI Agents

### Working In This Directory
- Modify the docker-compose file to adjust ports, volumes, or environment variables
- Ensure volume paths are absolute or properly relative to the project
- Do not change the service name without updating dependent references
- Requires host network mode and TUN device access (`/dev/net/tun`)
- Needs `NET_ADMIN` and `NET_RAW` capabilities for VPN functionality
- Configuration is loaded from `/etc/configs/easytier/.env` via env_file
- The `install.sh` script may be used for initial setup

### Testing Requirements
- Validate with: `docker compose -f docker-compose.yaml config`
- Check that exposed ports do not conflict with other services in this repo
- Verify `/etc/configs/easytier/.env` exists and contains valid configuration
- Ensure `/dev/net/tun` device is available on the host

### Common Patterns
- Standard Docker Compose single-service or multi-service stack
- Environment variables may be defined inline or in a separate `.env` file

## Dependencies

### External
- `easytier/easytier:latest` — Peer-to-peer VPN and mesh networking solution

<!-- MANUAL: -->
