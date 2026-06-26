#!/bin/sh
# Wrapper that sources ~/.env so mcp-hub child MCP servers inherit secrets,
# then execs mcp-hub. Service managers (launchd, systemd) do not read shell
# rc files, so this wrapper is the seam where env vars get loaded.
#
# Portable across macOS (launchd) and Linux (systemd --user) — no bash/zshisms.

set -e

if [ -f "$HOME/.env" ]; then
  set -a
  . "$HOME/.env"
  set +a
fi

# ---------------------------------------------------------------------------
# Idempotent patch for upstream mcp-hub bug:
#   src/mcp/server.js#handleSSEConnection registers the same cleanup callback
#   on BOTH res.on("close") AND transport.onclose. server.close() then calls
#   transport.close() which calls res.end() which fires the "close" event,
#   re-entering cleanup → server.close() → ... until V8 throws RangeError.
#   With Cursor connecting via ~/.cursor/mcp.json this fires every time
#   Cursor (re)opens a workspace, eventually killing the daemon.
#
# Fix: insert a re-entrancy guard so cleanup runs at most once per session.
# Re-applied on every launch because mcphub.nvim's build step does
# `npm install -g mcp-hub@latest` which reverts the patched dist/cli.js.
# Upstream PR: https://github.com/ravitemer/mcp-hub/pull/140
# Once that merges and a release ships, this whole patch block can go.
# ---------------------------------------------------------------------------
mcphub_cli="$(command -v mcp-hub 2>/dev/null || echo "$HOME/.local/bin/mcp-hub")"
mcphub_dist="$(readlink -f "${mcphub_cli}" 2>/dev/null || echo "")"
case "${mcphub_dist}" in
*/mcp-hub/dist/cli.js)
  if ! grep -q '_mcphubCleanupRan' "${mcphub_dist}" 2>/dev/null; then
    node -e '
        const fs = require("fs");
        const f = process.argv[1];
        const old = "let s,o=async()=>{this.clients.delete(a);";
        const neu = "let s,o=async()=>{if(o._mcphubCleanupRan)return;o._mcphubCleanupRan=!0;this.clients.delete(a);";
        const src = fs.readFileSync(f, "utf8");
        if (!src.includes(old)) { console.error("mcphub-launch: patch site not found in " + f); process.exit(0); }
        fs.writeFileSync(f, src.replace(old, neu));
        console.error("mcphub-launch: patched " + f + " (recursive-close guard)");
      ' "${mcphub_dist}" || :
  fi
  ;;
esac

exec "$HOME/.local/bin/mcp-hub" \
  --port 37373 \
  --config "$HOME/.config/mcphub/servers.json" \
  --watch \
  --auto-shutdown \
  --shutdown-delay 300000
