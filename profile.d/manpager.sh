#!/usr/bin/env sh
# manpager.sh: manual pager configuration

# Skip if MANPAGER is already set
if test -n "${MANPAGER:-}"; then
  export MANPAGER
  return 0
fi

# Set MANPAGER based on available editors/pagers
if command -v nvim > /dev/null; then
  export MANPAGER="nvim '+Man!'"
elif command -v vim > /dev/null; then
  export MANPAGER="vim -M +MANPAGER -"
elif command -v bat > /dev/null; then
  export MANPAGER="bat --language=Manpage --paging=always --color=always --style=grid,numbers --pager='less ${LESS:--QFRi --mouse} -X' -- -"
fi

# vim:ft=sh
