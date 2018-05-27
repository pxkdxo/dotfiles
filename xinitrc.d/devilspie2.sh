#!/usr/bin/env bash

##
## Start devilspie2 running as a daemon
##


if test -f "${XDG_RUNTIME_DIR}/devilspie2.pid"; then
  kill -15 "$(< "${XDG_RUNTIME_DIR}/devilspie2.pid")"
  rm "${XDG_RUNTIME_DIR}/devilspie2.pid"
fi

devilspie2 &
printf '%d\n' "$!" >| "${XDG_RUNTIME_DIR}/devilspie2.pid"
