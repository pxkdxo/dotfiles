#!/usr/bin/env sh
# surfraw.sh: surfraw elvi path config

if command -v surfraw > /dev/null; then
  # Add surfraw elvi directory to PATH
  for surfraw_dir in /usr/local/lib/surfraw /usr/lib/surfraw /lib/surfraw; do
    if test -d "${surfraw_dir}"; then
      case ":${PATH}:" in
        *":${surfraw_dir}:"*) ;;
        *) export PATH="${PATH:+${PATH}:}${surfraw_dir}" ;;
      esac
      break
    fi
  done
  unset surfraw_dir
fi

# vim:ft=sh
