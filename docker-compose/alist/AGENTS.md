<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# alist

## Purpose
AList is a file list program that supports multiple storage providers, allowing users to mount and browse files from various cloud storage services (Google Drive, OneDrive, Aliyun Drive, etc.) through a unified web interface accessible on port 5244.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | Docker Compose configuration for AList |

## For AI Agents

### Working In This Directory
- Modify the docker-compose file to adjust ports, volumes, or environment variables
- Ensure volume paths are absolute or properly relative to the project
- Do not change the service name without updating dependent references

### Testing Requirements
- Validate with: `docker compose -f docker-compose.yaml config`
- Check that exposed ports do not conflict with other services in this repo

### Common Patterns
- Standard Docker Compose single-service or multi-service stack
- Environment variables may be defined inline or in a separate `.env` file

## Dependencies

### External
- `xhofe/alist:${IMAGE_TAG:-latest}` — Multi-storage file list and management web application

<!-- MANUAL: -->
