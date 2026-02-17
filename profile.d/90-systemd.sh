#!/usr/bin/env sh
# ~/profile.d/systemd.sh: Set environment variables for systemd

export SYSTEMD_LESS='-FiQRSX --mouse'

if test -n "${COLORTERM-}" && { test "${COLORTERM}" = 'truecolor' || test "${COLORTERM}" = '24bit'; }; then
  export SYSTEMD_COLORS='true'
else
  case "${TERM-}" in
    ?*-truecolor*)
      export SYSTEMD_COLORS='true' ;;
    alacritty|alacritty-?*|xterm-alacritty)
      export SYSTEMD_COLORS='true' ;;
    foot|foot-?*|xterm-foot)
      export SYSTEMD_COLORS='true' ;;
    ghostty|ghostty-?*|xterm-ghostty)
      export SYSTEMD_COLORS='true' ;;
    iterm2|iterm2-?*|xterm-iterm2)
      export SYSTEMD_COLORS='true' ;;
    kitty|kitty-?*|xterm-kitty)
      export SYSTEMD_COLORS='true' ;;
    konsole|konsole-?*|xterm-konsole)
      export SYSTEMD_COLORS='true' ;;
    mintty|mintty-?*|xterm-mintty)
      export SYSTEMD_COLORS='true' ;;
    st|st-?*|xterm-st)
      export SYSTEMD_COLORS='true' ;;
    wezterm|wezterm-?*|xterm-wezterm)
      export SYSTEMD_COLORS='true' ;;
    tmux-256*)
      export SYSTEMD_COLORS='true' ;;
    xterm-256*)
      export SYSTEMD_COLORS='true' ;;
    *-256*)
      export SYSTEMD_COLORS=256 ;;
    *) 
      if REPLY="$(tput colors 2>/dev/null)"; then
        if "${REPLY:-0}" -ge 256; then
          export SYSTEMD_COLORS=256
        elif "${REPLY:-0}" -ge 88; then
          export SYSTEMD_COLORS=88
        elif "${REPLY:-0}" -ge 16; then
          export SYSTEMD_COLORS=16
        fi
      fi 
      ;;
  esac
fi

# vim:ft=sh
