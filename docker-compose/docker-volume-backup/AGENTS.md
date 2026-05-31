<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# docker-volume-backup

## Purpose
Docker Volume Backup is a scheduled backup solution for Docker volumes. It backs up Docker volume data to an archive location, reading configuration from an environment file and mounting the Docker volumes directory read-only for safe backup operations.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | Docker Compose configuration for docker-volume-backup |
| `backup.env` | Environment configuration for backup settings |
| `backup copy.env` | Backup copy of environment configuration |

## For AI Agents

### Working In This Directory
- Modify the docker-compose file to adjust ports, volumes, or environment variables
- Ensure volume paths are absolute or properly relative to the project
- Do not change the service name without updating dependent references
- Review `backup.env` for backup schedule, retention, and destination settings
- The service mounts `/var/lib/docker/volumes/` read-only for safe backup

### Testing Requirements
- Validate with: `docker compose -f docker-compose.yaml config`
- Check that exposed ports do not conflict with other services in this repo
- Verify backup.env contains valid configuration values

### Common Patterns
- Standard Docker Compose single-service or multi-service stack
- Environment variables may be defined inline or in a separate `.env` file

## Dependencies

### External
- `offen/docker-volume-backup:v2.44.0` — Docker volume backup and archiving tool

<!-- MANUAL: -->
