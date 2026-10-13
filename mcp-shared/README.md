# Shared MCP setup

Dotfiles contains the canonical `servers.json`, Python supervisor and locked dependencies,
and a vendored snapshot of our `pxkdxo/mcp-client.nvim` Lua client (including the reviewed
adapter/session fixes). No checkout under Documents or private GitHub access is required.
The client snapshot comes from `https://github.com/pxkdxo/mcp-client.nvim` at base
commit `a4263652e55d51dd9fde6c68c0abe76a50922a95`, plus the adapter, session and native-bridge fixes
validated during this migration. Update the vendored Lua source deliberately; it is not downloaded
from an uncommitted branch on installation.

## New machine

1. Clone dotfiles and run `./install-dotfiles.sh` (submodules as described in the main README).
2. Install `uv`, Node.js/npm and Homebrew. `uv` installs Python 3.13 when needed.
   Homebrew must support `brew mcp-server`. The backend package versions are in the inventory.
3. Restore private `~/.env` with `ATLASSIAN_API_TOKEN`, `ATLASSIAN_URL`,
   `ATLASSIAN_USERNAME`, `AWS_REGION`, `CONTEXT7_API_KEY` and `GITHUB_PERSONAL_ACCESS_TOKEN`.
   Set file permissions to 600. Restore AWS profiles/credentials separately if using AWS tools.
4. Run `./setup-mcp.sh`. It installs the lockfile, preflights commands and variables,
   merges Codex, Cursor and Claude Code connections while preserving unrelated entries, backs up changed
   files beside their originals, retires the old hub service, and starts the new service.
5. Restart Neovim/Codex/Cursor/Claude Code. Cursor may require enabling the new MCP connections.
   Authenticate ACP agents independently. Browser tools also need their browser companion;
   Puppeteer may download its browser on first use. Discovery does not validate upstream
   account permissions or those external companions.

The generic installer does not activate MCP. `setup-mcp.sh` is the explicit network and
credential-dependent setup step. Re-running it refreshes config and restarts the service.
`./setup-mcp.sh --prepare-only` writes configuration without credential preflight or activation.
Missing runtime/credentials disable Neovim MCP integration with a warning; normal editing loads.

Generated connection files stay under `~/.config/mcp-shared/` and are ignored by git.
The service uses `~/.local/state/mcp-shared/`. Do not commit `.venv`, state, dotenv files,
generated connections, or config backups. `string.Template` expands `$NAME`/`${NAME}` once
in memory; no shell eval. Python reads dotenv with interpolation disabled. Inherited process
environment takes precedence. Empty or missing credential placeholders fail preflight.

Codex's native `http_headers_helper` invokes `codex_headers.py` for hosted headers, so GUI
launches can read `~/.env` without shell-variable inheritance. The script prints headers only
to Codex's pipe. The proxy handles local stdio servers; hosted GitHub/Context7 stay direct.

## Service managers

macOS: `launchctl print gui/$(id -u)/com.patrickdeyoreo.mcp-shared`;
logs in `~/Library/Logs/mcp-shared.err.log`. Setup waits through launchd's asynchronous unload.

Linux: `systemctl --user status mcp-shared.service` and
`journalctl --user -u mcp-shared.service`. The generated unit enables at user login, uses
`KillMode=control-group` to clean up all descendants, and gives shutdown 45 seconds.
`Restart=no` leaves restart budgeting to the supervisor, matching launchd's `KeepAlive=false`.
A failed supervisor/budget needs manual `systemctl --user restart mcp-shared.service`.
The user bus must be available during setup. To run after logout, deliberately enable lingering
with `loginctl enable-linger "$USER"` on the Linux machine; setup does not change that policy.

Standard Apple Silicon, Intel, Linuxbrew, and custom dotfiles Homebrew paths are included.
A reachable loopback port 37373 is required. The supervisor refuses a competing listener.
Local backend failure can restart the whole backend set; interrupted calls are never replayed.

## Verification

```sh
mcp-shared/.venv/bin/python -m unittest discover -s mcp-shared -p 'test_*.py'
sh -n install-dotfiles.sh setup-mcp.sh
```

Fresh-home tests cover both generated service types, a home containing spaces, repeat runs,
config preservation and absence of the original user's paths. Recovery tests cover backend
failure, timeout, bounded retry exhaustion and cleanup. Native orchestrator tools stay inside
Neovim; its legacy `plan_detail` resource template is omitted by the compatibility bridge.

Verified on 2026-10-13: all 11 production local endpoints and a real time call passed
after relocation; macOS setup was rerun successfully. Fourteen Python tests passed.
The generated Linux unit passed `systemd-analyze --user verify` on systemd 259 in
a Fedora VM, then two HTTP clients shared one synthetic backend PID and stopping
the unit removed the proxy and all captured descendants. That VM test used its
Python 3.14; the bootstrap installs locked dependencies with Python 3.13.
Production credentials and every real backend were validated on macOS, not on Linux.

Claude Code uses user-scope HTTP servers in `~/.claude.json` (or the active
`CLAUDE_CONFIG_DIR` during normal setup). Managed local-scope overrides in its
`projects` map are removed so they cannot shadow shared endpoints; unrelated MCP
servers and trust/preferences are preserved. Hosted authentication uses Claude
Code's native `headersHelper` with the same private dotenv reader as Codex.
Project `.mcp.json` files can override user scope; audit them when joining a new
repository. Setup does not rewrite team-owned project configuration.
