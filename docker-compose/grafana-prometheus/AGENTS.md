<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# grafana-prometheus

## Purpose
A monitoring stack combining Prometheus (port 9090) for metrics collection and storage, and Grafana (port 9091) for visualization and dashboards. Prometheus scrapes metrics from configured targets with a 200-hour retention period, while Grafana provides a web interface for creating and viewing dashboards.

## Key Files
| File | Description |
|------|-------------|
| `docker-compose.yaml` | Docker Compose configuration for Prometheus and Grafana |

## For AI Agents

### Working In This Directory
- Modify the docker-compose file to adjust ports, volumes, or environment variables
- Ensure volume paths are absolute or properly relative to the project
- Do not change the service name without updating dependent references
- Prometheus admin API and lifecycle endpoints are enabled for management
- Grafana runs as root (user "0") for volume permission compatibility
- The `extra_hosts` entry maps `local-server` to the host gateway for scraping local exporters
- Data retention is set to 200 hours via `--storage.tsdb.retention.time=200h`

### Testing Requirements
- Validate with: `docker compose -f docker-compose.yaml config`
- Check that exposed ports do not conflict with other services in this repo
- Verify Prometheus is accessible at port 9090 and Grafana at port 9091

### Common Patterns
- Standard Docker Compose single-service or multi-service stack
- Environment variables may be defined inline or in a separate `.env` file

## Dependencies

### External
- `prom/prometheus:v3.2.1` — Time-series metrics collection and monitoring system
- `grafana/grafana-oss` — Metrics visualization and dashboard platform

<!-- MANUAL: -->
