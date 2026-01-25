#!/usr/bin/env sh
# ~/profile.d/systemd.sh: Set environment variables for systemd


case "${COLORTERM}" in
  truecolor|24bit) 
    SYSTEMD_COLORS='true'
    ;;
  *)
    case "${TERM}" in
      *-truecolor*|alacritty|alacritty-*|foot|foot-*|iterm2|iterm2-*|kitty|kitty-*|konsole|konsole-*|mintty|mintty-*|st|st-*|wezterm|wezterm-*|xterm2-256*|xterm-iterm2|xterm-kitty|xterm-konsole)
        export SYSTEMD_COLORS='true'
        ;;
      *-256*)
        export SYSTEMD_COLORS=256
        ;;
      *) 
        if test "$(tput colors || echo 0)" -ge 256 2>/dev/null; then
          export SYSTEMD_COLORS=256
        elif test "$(tput colors || echo 0)" -ge 16 2>/dev/null; then
          export SYSTEMD_COLORS=16
        fi
        ;;
    esac
    ;;
esac
export SYSTEMD_LESS="${LESS:--RFiq --mouse} -X"

# vim:ft=sh
