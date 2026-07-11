#!/usr/bin/env sh
# mpd.sh: point MPD clients at the user socket
# Mirrors environment.d/40-mpd.conf for non-systemd contexts (macOS, ssh).
# Without a runtime dir, clients' own localhost default is the right answer.

if test -n "${XDG_RUNTIME_DIR:-}"; then
  export MPD_HOST="${MPD_HOST:-${XDG_RUNTIME_DIR}/mpd/socket}"
fi
export MPD_PORT="${MPD_PORT:-6600}"

# vim:ft=sh
