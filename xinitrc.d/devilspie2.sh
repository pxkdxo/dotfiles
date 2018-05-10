#!/usr/bin/env bash

##
## Start devilspie2 running as a daemon
##

if [[ -f ${XDG_RUNTIME_DIR}/devilspie2@${DISPLAY}.pid ]] \
&& [[ -f ${XDG_RUNTIME_DIR}/devilspie2@${DISPLAY}.pid ]]
then
  kill -15 "$(< "${XDG_RUNTIME_DIR}/devilspie2@${DISPLAY}.pid")"
  rm "${XDG_RUNTIME_DIR}/devilspie2@${DISPLAY}.pid"
fi

devilspie2 &

printf '%d\n' "$!" >| "${XDG_RUNTIME_DIR}/devilspie2@${DISPLAY}.pid"
