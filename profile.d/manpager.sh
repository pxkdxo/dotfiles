#!/usr/bin/env sh
# manpager.sh: man page pager

if command -v nvim > /dev/null; then
  export MANPAGER="nvim +Man!"
elif command -v vim > /dev/null; then
  export MANPAGER="vim -M +MANPAGER -"
elif command -v bat > /dev/null; then
  export MANPAGER="bat --language=Manpage --paging=always --color=always --style=header,grid,snip --pager='less ${LESS:--iFQR --mouse} -X' -- -"
fi

# vim:ft=sh
