#!/usr/bin/env sh
#
# gh.sh: GitHub CLI environment config

export GH_CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/gh"

export GLAMOUR_STYLE=auto

if command -v gh > /dev/null; then
  if command -v bat > /dev/null; then
    export GH_PAGER=bat
  elif command -v nvimpager > /dev/null; then
    export GH_PAGER='nvimpager -p'
  elif command -v less > /dev/null; then
    export GH_PAGER='less'
  fi
  unset GH_COLOR_LABELS
  case "${COLORTERM:-}" in (truecolor)
    export GH_COLOR_LABELS=true ;;
  esac
  case "${TERM#*-}" in (truecolor|256*)
    export GH_COLOR_LABELS=true ;;
  esac
  case "${TERM%%-*}" in (allacrity|linux|st|vte|xterm|rvxt|kitty|foot|iterm2|tmux|konsole)
    export GH_COLOR_LABELS=true ;;
  esac
fi
