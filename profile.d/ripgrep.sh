#!/usr/bin/env sh
# ripgrep.sh: Set ripgrep config path if it exists

if test -r "${XDG_CONFIG_HOME:-${HOME}/.config}/ripgrep/ripgreprc"; then
  export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME:-${HOME}/.config}/ripgrep/ripgreprc"
elif test -r "${XDG_CONFIG_HOME:-${HOME}/.config}/ripgreprc"; then
  export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME:-${HOME}/.config}/ripgreprc"
elif test -r "${HOME}/.ripgrep/ripgreprc"; then
  export RIPGREP_CONFIG_PATH="${HOME}/.ripgrep/ripgreprc"
elif test -r "${HOME}/.ripgreprc"; then
  export RIPGREP_CONFIG_PATH="${HOME}/.ripgreprc"
fi
