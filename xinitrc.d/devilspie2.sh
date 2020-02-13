#!/usr/bin/env sh
#
# Start devilspie2 as a daemon

if command -v devilspie2
then
  pgrep -fxu "${USER:-$(id -un)}" devilspie2 || exec devilspie2 &
fi 1> /dev/null 2>&1

# vi:ft=sh
