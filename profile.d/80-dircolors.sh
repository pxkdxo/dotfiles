#!/usr/bin/env sh
# dircolors.sh : dircolors configuration
# see dircolors(1)

if command -v dircolors > /dev/null; then
  if test -f "${XDG_CONFIG_HOME:-${HOME}/.config}/dircolors"; then
    eval "$(dircolors "${XDG_CONFIG_HOME:-${HOME}/.config}/dircolors")"
  elif test -f ~/.dircolors; then
    eval "$(dircolors ~/.dircolors)"
  else
    eval "$(dircolors)"
  fi && export LS_COLORS
fi

# vim:ft=sh
