#!/usr/bin/env sh
# gh.sh: GitHub CLI environment config

# GitHub CLI config directory
export GH_CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/gh"

# Glow MD viewer style
export GLAMOUR_STYLE="auto"

if command -v gh > /dev/null; then

  # GitHub CLI pager
  if test -n "${PAGER:-}"; then
    export GH_PAGER="${PAGER}"
  elif command -v bat > /dev/null; then
    export GH_PAGER='bat'
  elif command -v nvimpager > /dev/null; then
    export GH_PAGER='nvimpager -p'
  fi
  
  # Enable color labels for terminals that can handle it
  unset GH_COLOR_LABELS

  case "${COLORTERM:-}" in
    truecolor|24bit)
      export GH_COLOR_LABELS=true
      ;;
  esac
  case "${TERM#*-}" in
    truecolor|direct|256*)
      export GH_COLOR_LABELS=true
      ;;
  esac
  case "${TERM}" in
    alacritty|alacritty-*|foot|foot-*|iterm2|iterm2-*|kitty|kitty-*|konsole|konsole-*|mintty|mintty-*|st|st-*|wezterm|wezterm-*|xterm-iterm2|xterm-kitty|xterm-konsole)
      export GH_COLOR_LABELS=true
      ;;
  esac
fi

# vim:ft=sh
