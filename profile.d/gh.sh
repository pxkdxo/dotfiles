#!/usr/bin/env sh
#
# gh.sh: GitHub CLI environment config

export GH_CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/gh"

export GLAMOUR_STYLE="auto"

if command -v gh > /dev/null; then
  if test -n "${PAGER}"; then
    export GH_PAGER="${PAGER}"
  elif command -v bat > /dev/null; then
    export GH_PAGER='bat'
  elif command -v nvimpager > /dev/null; then
    export GH_PAGER='nvimpager -p'
  fi
  unset GH_COLOR_LABELS
  case "${COLORTERM:-}" in
    truecolor)
      export GH_COLOR_LABELS=true ;;
  esac
  case "${TERM#*-}" in
    truecolor|direct|256*)
      export GH_COLOR_LABELS=true ;;
  esac
  case "${TERM%%-*}" in
    alacritty|foot|iterm2|kitty|konsole|linux|st|wezterm|rxvt-unicode)
      export GH_COLOR_LABELS=true ;;
  esac
fi
