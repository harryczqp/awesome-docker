<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# home

## Purpose
Custom dashboard frontend for the Nginx Proxy Manager deployment. A static HTML/JS/CSS mini-application providing a personalized home page or service directory.

## Key Files
| File | Description |
|------|-------------|
| `index.html` | Main HTML page for the dashboard |
| `script.js` | JavaScript logic for the dashboard |
| `style.css` | CSS styling for the dashboard |

## Subdirectories
None.

## For AI Agents

### Working In This Directory
- This is a static frontend; serve via Nginx or NPM proxy host.
- Modify `index.html`, `script.js`, or `style.css` to update the dashboard.
- No Docker Compose file here; it is part of the parent `npm/` deployment.

### Testing Requirements
- Open `index.html` in a browser or serve via a local HTTP server.
- Verify JS functionality and CSS rendering.

### Common Patterns
- Static asset directory meant to be served by the parent NPM reverse proxy.

## Dependencies

### Internal
- `npm/` — served through the Nginx Proxy Manager.

### External
- None.

<!-- MANUAL: -->
