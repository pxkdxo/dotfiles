#!/usr/bin/env sh

## Start compton in the background as a daemon

if command -v compton 1>/dev/null; then
  if test -f "${XDG_RUNTIME_DIR}/compton.pid"; then
    if test -r "${XDG_RUNTIME_DIR}/compton.pid"; then
      kill -15 "$(cat "${XDG_RUNTIME_DIR}/compton.pid")"
    fi
    rm "${XDG_RUNTIME_DIR}/compton.pid"
  fi

  compton --daemon --dbus --write-pid-path "${XDG_RUNTIME_DIR}/compton.pid"
fi
