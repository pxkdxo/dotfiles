#!/usr/bin/env sh
# ~/profile.d/systemd.sh: Set environment variables for systemd


case "${COLORTERM}" in
  truecolor|24bit) 
    SYSTEMD_COLORS='true'
    ;;
  *)
    case "${TERM}" in
      *-direct*|*-truecolor*|st|st-*|foot|foot-*|alacritty|alacritty-*|mintty|mintty-*|wezterm|wezterm-*|iterm2|iterm2-*|xterm-iterm2|konsole|konsole-*|xterm-konsole|kitty|kitty-*|xterm-kitty|tmux-256*)
        export SYSTEMD_COLORS='true'
        ;;
      *-256*)
        export SYSTEMD_COLORS=256
        ;;
      *-88*|*-16*|*-*color|*-*ansi*)
        if test "$(tput colors || echo 0)" -ge 256 2>/dev/null; then
          export SYSTEMD_COLORS=256
        else
          export SYSTEMD_COLORS=16
        fi
        ;;
      *) 
        if test "$(tput colors || echo 0)" -ge 256 2>/dev/null; then
          export SYSTEMD_COLORS=256
        elif setest "$(tput colors || echo 0)" -ge 16 2>/dev/null; then
          export SYSTEMD_COLORS=16
        fi
        ;;
    esac
    ;;
esac
export SYSTEMD_LESS="${LESS:--RFiq --mouse} -X"

