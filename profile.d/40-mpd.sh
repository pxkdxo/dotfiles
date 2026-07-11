#!/usr/bin/env sh
# mpd.sh: point MPD clients (ncmpcpp, mpc, ...) at the user socket
#
# Mirror of environment.d/40-mpd.conf for contexts without the systemd user
# manager (macOS, ssh logins, termux). Only exported when the runtime dir is
# available; otherwise clients fall back to their own localhost default,
# which is also the right answer on macOS.

if test -n "${XDG_RUNTIME_DIR:-}"; then
  export MPD_HOST="${MPD_HOST:-${XDG_RUNTIME_DIR}/mpd/socket}"
fi
export MPD_PORT="${MPD_PORT:-6600}"

# vim:ft=sh
