#!/usr/bin/env sh

## Start devilspie2 in the background as a daemon

if command -v compton 1>/dev/null; then
  if test -f "${XDG_RUNTIME_DIR}/devilspie2.pid"; then
    if test -r "${XDG_RUNTIME_DIR}/devilspie2.pid"; then
      kill -15 "$(cat "${XDG_RUNTIME_DIR}/devilspie2.pid")"
    fi
    rm "${XDG_RUNTIME_DIR}/devilspie2.pid"
  fi

  devilspie2 & echo "$!" 1>| "${XDG_RUNTIME_DIR}/devilspie2.pid"
fi
