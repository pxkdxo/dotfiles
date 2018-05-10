#!/usr/bin/env bash

##
## Start compton running as a daemon
##

if test -f "${XDG_RUNTIME_DIR}/compton@${DISPLAY}.pid" \
&& test -r "${XDG_RUNTIME_DIR}/compton@${DISPLAY}.pid"
then
  kill -15 "$(< "${XDG_RUNTIME_DIR}/compton@${DISPLAY}.pid")"
  rm "${XDG_RUNTIME_DIR}/compton@${DISPLAY}.pid"
fi

compton     \
  --daemon  \
  --dbus    \
  --write-pid-path "${XDG_RUNTIME_DIR}/compton@${DISPLAY}.pid"
