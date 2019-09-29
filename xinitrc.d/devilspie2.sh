#!/usr/bin/env sh

# Start devilspie2 as a daemon

#if command -v devilspie2 1>/dev/null
#then
#    pidof devilspie2 |
#        while read -r REPLY
#        do
#            kill -s TERM "${REPLY}"
#        done
#  devilspie2 & printf '%d' "$!" 1>| "${XDG_RUNTIME_DIR}/devilspie2.pid"
#fi
