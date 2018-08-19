#!/usr/bin/env sh

## Start compton in the background as a daemon

test -f "${XDG_RUNTIME_DIR}/compton.pid" && \
test -r "${XDG_RUNTIME_DIR}/compton.pid" && {
  kill -15 "$(cat "${XDG_RUNTIME_DIR}/compton.pid")"
  rm "${XDG_RUNTIME_DIR}/compton.pid"
} 2>/dev/null

compton --daemon --dbus --write-pid-path "${XDG_RUNTIME_DIR}/compton.pid"

#pkill -15 compton
#pgrep compton 1>/dev/null && pkill -9 compton
#
#compton --daemon --dbus
