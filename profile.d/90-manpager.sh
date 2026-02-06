#!/usr/bin/env sh
# manpager.sh: man page pager

if command -v nvim > /dev/null; then
  export MANPAGER="nvim +Man!"
elif command -v vim > /dev/null; then
  export MANPAGER="vim -M +MANPAGER -"
elif command -v bat > /dev/null; then
  export MANPAGER="bat --language=Manpage --paging=always --decorations=auto --color=auto --style=grid,snip --pager='less ${LESS:--FiQRSX --mouse}' -- -"
fi

# vim:ft=sh
