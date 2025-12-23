#!/usr/bin/env sh
# dircolors.sh : dircolors config
# see dircolors(1)

if command -v dircolors > /dev/null; then
  LS_COLORS="$(
  if test -f "${XDG_CONFIG_HOME:-${HOME}/.config}/dircolors"; then
    dircolors -- "${XDG_CONFIG_HOME:-${HOME}/.config}/dircolors"
  elif test -f "${HOME}/.dircolors"; then
    dircolors -- "${HOME}/.dircolors"
  else
    dircolors
  fi | head -n 1 | cut -f 2 -d "'"
  )"
  export LS_COLORS
fi 2> /dev/null

# vim:ft=sh
