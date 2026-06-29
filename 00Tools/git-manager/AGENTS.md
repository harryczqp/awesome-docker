<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-31 | Updated: 2026-05-31 -->

# git-manager

## Purpose
A Python CLI tool for scanning and restoring Git repository metadata across deeply nested directory structures. The `scan` command recursively finds all `.git` folders, records each repository's relative path, remote origin URL, and current branch into a CSV file. The `restore` command reads that CSV and re-initializes Git remotes inside existing source directories, making it useful for disaster recovery or NAS migration scenarios.

## Key Files
| File | Description |
|------|-------------|
| `run.py` | Main Python script. Implements `scan` and `restore` subcommands using `argparse`, `os.walk()`, and `subprocess.run()`. |

## For AI Agents

### Working In This Directory
- This is a single-file tool; all logic resides in `run.py`.
- The `scan` command uses `os.walk()` with directory pruning (`dirs.remove()`) to skip `.git`, `node_modules`, `target`, `dist`, `venv`, and `__pycache__`.
- The `restore` command skips repositories where `.git` already exists or where the target directory is missing.
- CSV format: `relative_path,remote_url,branch`.
- `run_git_cmd()` uses `shell=True` with `subprocess.run()`.

### Testing Requirements
- Test `scan` on a directory tree containing multiple Git repos at varying depths.
- Verify the generated CSV has correct relative paths and branch names.
- Test `restore` on a copy of the scanned directory tree with `.git` folders removed.
- Ensure `git` is available in PATH.

### Common Patterns
- `os.walk()` with `dirs.remove()` for pruning unwanted directories during recursion.
- `csv.DictReader` / `csv.writer` for CSV I/O.
- `subprocess.run(..., shell=True, check=True)` for Git command execution.
- `shutil.rmtree()` for cleaning up failed restore attempts.
- Chinese-language print output and comments.

## Dependencies

### Internal
- None.

### External
- Python 3.
- Git installed and available in PATH.

<!-- MANUAL: -->
