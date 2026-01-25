#!/usr/bin/env sh
# clipboard.sh: clipboard copy/paste functions
# Use cbcopy / cbpaste wherever this is loaded

cbdetect() {
  # shellcheck disable=SC2329
  if case "$(uname -s)" in
    Darwin*|darwin*)
      {
        command -v pbcopy && command -v pbpaste
      } > /dev/null && {
        cbcopy() { cat "${1:-/dev/stdin}" | pbcopy; }
        cbpaste() { pbpaste; }
      }
      ;;
    Linux*Android*|Linux*android*|linux*android*)
      {
        command -v termux-clipboard-set && command -v termux-clipboard-get
      } > /dev/null && {
        cbcopy() { cat "${1:-/dev/stdin}" | termux-clipboard-set; }
        cbpaste() { termux-clipboard-get; }
      }
      ;;
    Cygwin*|cygwin*|Msys*|msys*)
      cbcopy() { cat "${1:-/dev/stdin}" > /dev/clipboard; }
      cbpaste() { cat /dev/clipboard; }
      ;;
    *)
      false
      ;;
  esac
  then
    :
  elif test "${XDG_SESSION_TYPE:-}" = "wayland" \
    && test -n "${WAYLAND_DISPLAY:-}" \
    && command -v wl-copy > /dev/null; then
    cbcopy() { cat "${1:-/dev/stdin}" | wl-copy -n > /dev/null 2>&1 & }
    cbpaste() { wl-paste --no-newline; }
  elif test "${XDG_SESSION_TYPE:-}" = "x11" \
    && test -n "${DISPLAY:-}" \
    && command -v xsel > /dev/null; then
    cbcopy() { cat "${1:-/dev/stdin}" | xsel --clipboard --input -n; }
    cbpaste() { xsel --clipboard --output; }
  elif test "${XDG_SESSION_TYPE:-}" = "x11" \
    && test -n "${DISPLAY:-}" \
    && command -v xclip > /dev/null; then
    cbcopy() { cat "${1:-/dev/stdin}" | xclip -selection clipboard -in > /dev/null 2>&1 & }
    cbpaste() { xclip -out -selection clipboard; }
  elif command -v lemonade > /dev/null; then
    cbcopy() { cat "${1:-/dev/stdin}" | lemonade copy; }
    cbpaste() { lemonade paste; }
  elif command -v doitclient > /dev/null; then
    cbcopy() { cat "${1:-/dev/stdin}" | doitclient wclip; }
    cbpaste() { doitclient wclip -r; }
  elif command -v win32yank > /dev/null; then
    cbcopy() { cat "${1:-/dev/stdin}" | win32yank -i; }
    cbpaste() { win32yank -o; }
  elif test -n "${TMUX:-}" && command -v tmux > /dev/null; then
    cbcopy() { tmux load-buffer -w "${1:--}"; }
    cbpaste() { tmux save-buffer -; }
  else
    return 1
  fi
}

cbdetect
