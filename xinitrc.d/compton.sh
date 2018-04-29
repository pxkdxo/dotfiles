#!/usr/bin/env bash

#
## Start compton running as a daemon
#

[[ -f ${XDG_RUNTIME_DIR}/compton@${DISPLAY}.pid ]] && {
  kill -15 "$(< "${XDG_RUNTIME_DIR}/compton@${DISPLAY}.pid")"
  rm "${XDG_RUNTIME_DIR}/compton@${DISPLAY}.pid"
}

compton     \
  --daemon  \
  --dbus    \
  --write-pid-path "${XDG_RUNTIME_DIR}/compton@${DISPLAY}.pid"
