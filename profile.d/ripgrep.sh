#!/usr/bin/env sh
# ripgrep.sh: Set ripgrep config path if it exists

# Skip if already set
if test -n "${RIPGREP_CONFIG_PATH:-}"; then
  return 0
fi

# Check common locations for ripgrep config
for config_path in \
  "${XDG_CONFIG_HOME:-${HOME}/.config}/ripgrep/ripgreprc" \
  "${XDG_CONFIG_HOME:-${HOME}/.config}/ripgreprc" \
  "${HOME}/.ripgrep/ripgreprc" \
  "${HOME}/.ripgreprc"
do
  if test -r "${config_path}"; then
    export RIPGREP_CONFIG_PATH="${config_path}"
    return 0
  fi
done

# vim:ft=sh
