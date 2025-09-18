#!/usr/bin/env sh
# manpager.sh : manual pager configuration

# Use vim or nvim if availabe
if test -n "${MANPAGER}"; then
  export MANPAGER
elif command -v nvim > /dev/null; then
  export MANPAGER="${MANPAGER:-"nvim '+Man!'"}"
elif command -v vim > /dev/null; then
  export MANPAGER="${MANPAGER:-"vim -M +MANPAGER -"}"
elif command -v bat > /dev/null; then
  export MANPAGER="${MANPAGER:-"bat --language=Manpage --paging=always --color=always --style=grid,numbers --pager='less ${LESS:--QFRi --mouse} -X' -- -"}"
fi > /dev/null

# vim:ft=sh
