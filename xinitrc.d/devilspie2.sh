#!/usr/bin/env sh

## Start devilspie2 in the background as a daemon

test -f "${XDG_RUNTIME_DIR}/devilspie2.pid" && \
test -r "${XDG_RUNTIME_DIR}/devilspie2.pid" && {
  kill -15 "$(cat "${XDG_RUNTIME_DIR}/devilspie2.pid")"
  rm "${XDG_RUNTIME_DIR}/devilspie2.pid"
} 2>/dev/null

devilspie2 & printf '%d\n' "$!" >| "${XDG_RUNTIME_DIR}/devilspie2.pid"

#pkill -15 devilspie2
#pgrep devilspie2 1>/dev/null && pkill -9 devilspie2
#
#devilspie2 &
