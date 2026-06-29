<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# docker-volume-backup

## Purpose
A Python CLI utility for backing up, restoring, and managing Docker volumes. It lists all volumes with their associated containers, backs up only in-use volumes into timestamped `.tar` archives, supports optional container stop/start for data consistency, and can prune unused volumes. Old backups are automatically cleaned based on a configurable retention period.

## Key Files
| File | Description |
|------|-------------|
| `backup_volumes.py` | Main Python script implementing `list`, `backup`, `restore`, and `prune` subcommands. Uses `subprocess.run()` to invoke `docker` and `tar`. |
| `README.md` | Chinese-language documentation covering features, prerequisites, environment variable configuration, and usage examples. |

## For AI Agents

### Working In This Directory
- The script is a single-file CLI; add new commands by extending the `if __name__ == "__main__"` block.
- Environment variables control behavior: `DOCKER_BACKUP_DIR`, `STOP_CONTAINERS_FOR_BACKUP`, `BACKUP_RETENTION_DAYS`.
- Backup archives are named `docker_volumes_backup_YYYYMMDD_HHMMSS.tar`.
- During backup, volumes not ending in `_data` are renamed to `{container_name}_data` inside the tar archive for clarity.

### Testing Requirements
- Requires Docker Engine running and the executing user in the `docker` group.
- `restore` requires root (`sudo`) because it writes to `/var/lib/docker/volumes/`.
- Test with `python backup_volumes.py list` first to verify Docker connectivity.
- Use a test volume/container pair before running `backup`, `restore`, or `prune` on production data.

### Common Patterns
- `subprocess.run(["docker", ...], capture_output=True, text=True)` for all Docker interactions.
- `os.getenv()` with hardcoded defaults for configuration.
- `datetime.datetime.strptime()` for parsing backup filenames during retention cleanup.
- Interactive confirmation prompts for destructive operations (`restore`, `prune`).

## Dependencies

### Internal
- None.

### External
- Python 3.
- Docker Engine (daemon running, user in `docker` group).
- `tar` command available in PATH.
- Root privileges for `restore`.

<!-- MANUAL: -->
