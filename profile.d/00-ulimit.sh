#!/usr/bin/env sh
# Raise the soft open-file limit to at least 10240 (macOS GUI-launched
# terminals inherit launchd's 256).
case "$(ulimit -Sn)" in
  unlimited) ;;
  *)
    if [ "$(ulimit -Sn)" -lt 10240 ]; then
      ulimit -Sn 10240 2>/dev/null || ulimit -Sn "$(ulimit -Hn)" 2>/dev/null
    fi
    ;;
esac
