# Vardot Workspace — install the tools

Installs (or verifies) everything the [Vardot Workspace](https://github.com/Vardot/workspace)
needs on a fresh machine: git, gh, curl, wget, jq, rsync, unzip, python3, gawk, Node.js
(npm + npx, which also powers the [skills.sh](https://skills.sh) CLI), Docker, DDEV and
gitlab-ci-local. Idempotent — whatever is already installed is left alone.

## Run it

```
bash <(wget -O - https://raw.githubusercontent.com/vardot/cmd/main/workspace/install-tools.sh)
```

| Flag | What it does |
| --- | --- |
| `--check` | Report what is present and what is missing, install nothing |
| `-y` | Install everything missing without asking per group |

## Platforms

- **Linux** — Debian/Ubuntu (apt) and Fedora (dnf); official installers for gh, Node.js LTS,
  Docker (get.docker.com) and DDEV (ddev.com/install.sh).
- **macOS** — Homebrew for everything; Docker itself via Docker Desktop or OrbStack.
- **Windows** — run it inside WSL2 (`wsl --install -d Ubuntu`); the script detects a native
  Windows shell and prints exactly these steps.

## Then

1. `gh auth login`
2. Clone [github.com/Vardot/workspace](https://github.com/Vardot/workspace) (branch `1.0.x`) —
   its README takes it from there.

The canonical copy of this script lives in that repository as `core/scripts/install.sh`.
