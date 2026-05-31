<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# openresty

## Purpose
OpenResty Alpine-based web platform extending Nginx with LuaJIT. Includes a WAF cache (100m shared dict), Lua module loading from `/etc/nginx/lua`, and standard reverse proxy capabilities. Uses host networking with 512M memory and 1.0 CPU limits.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yml` | OpenResty service definition with Lua/WAF support |
| `nginx.conf` | Main Nginx configuration with Lua shared dict and package path |

## Subdirectories
None.

## For AI Agents

### Working In This Directory
- Host paths required: `/var/log/nginx`, `/etc/configs/nginx/{conf.d,html,ssl,lua}`.
- Lua scripts should be placed in `/etc/configs/nginx/lua/` on the host.
- Uses `network_mode: host`; ensure no port conflicts with Nginx.

### Testing Requirements
- Validate config: `openresty -t` inside container.
- Verify Lua modules load correctly via error logs.

### Common Patterns
- `lua_shared_dict waf_cache 100m` for in-memory WAF caching.
- `lua_package_path` points to host-mounted Lua directory.
- Gzip, proxy timeouts, and header forwarding configured in nginx.conf.

## Dependencies

### Internal
- None.

### External
- `openresty/openresty:alpine`

<!-- MANUAL: -->
