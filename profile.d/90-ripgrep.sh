#!/usr/bin/env sh
# ripgrep.sh: Set ripgrep config path if it exists

if test -z "${RIPGREP_CONFIG_PATH:-}"; then
  for config_path in \
    "${XDG_CONFIG_HOME:-${HOME}/.config}/ripgrep/ripgreprc" \
    "${XDG_CONFIG_HOME:-${HOME}/.config}/ripgreprc" \
    "${HOME}/.ripgrep/ripgreprc" \
    "${HOME}/.ripgreprc"; do
    if test -r "${config_path}"; then
      export RIPGREP_CONFIG_PATH="${config_path}"
      break
    fi
  done
fi

# vim:ft=sh
