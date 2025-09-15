#!/usr/bin/env sh
# manpager.sh : manual pager configuration

# Use vim or nvim if availabe
if command -v nvim; then
  export MANPAGER='nvim +Man!'
elif command -v vim; then
  export MANPAGER='vim -M +MANPAGER -'
elif command -v bat; then
  export MANPAGER='bat --language=man --paging=always --style=grid,rule,numbers,snip'
fi > /dev/null

# vim:ft=sh
