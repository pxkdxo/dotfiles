#!/usr/bin/env sh
# gh.sh: GitHub CLI environment config

export GH_CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/gh"
export GLAMOUR_STYLE="auto"

if command -v gh > /dev/null; then
  # Set GH_PAGER based on available pagers
  if test -n "${PAGER:-}"; then
    export GH_PAGER="${PAGER}"
  elif command -v bat > /dev/null; then
    export GH_PAGER='bat'
  elif command -v nvimpager > /dev/null; then
    export GH_PAGER='nvimpager -p'
  fi
  
  # Enable color labels for terminals that support it
  enable_colors=false
  
  case "${COLORTERM:-}" in
    truecolor|24bit)
      enable_colors=true
      ;;
  esac
  
  case "${TERM#*-}" in
    truecolor|direct|256*)
      enable_colors=true
      ;;
  esac
  
  case "${TERM%%-*}" in
    alacritty|foot|iterm2|kitty|konsole|linux|st|wezterm|rxvt-unicode)
      enable_colors=true
      ;;
  esac
  
  if test "$enable_colors" = "true"; then
    export GH_COLOR_LABELS=true
  else
    unset GH_COLOR_LABELS
  fi
  unset enable_colors
fi

# vim:ft=sh
