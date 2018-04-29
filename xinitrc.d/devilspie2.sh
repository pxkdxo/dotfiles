#!/usr/bin/env bash

#
## Start devilspie2 running as a daemon
#

[[ -f ${XDG_RUNTIME_DIR}/devilspie2@${DISPLAY}.pid ]] && {
  kill -15 "$(< "${XDG_RUNTIME_DIR}/devilspie2@${DISPLAY}.pid")"
  rm "${XDG_RUNTIME_DIR}/devilspie2@${DISPLAY}.pid"
}

devilspie2 &

printf '%d\n' "$!" >| "${XDG_RUNTIME_DIR}/devilspie2@${DISPLAY}.pid"
