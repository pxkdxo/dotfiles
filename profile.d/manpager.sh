## manpager.sh : man pager configuration


## If nvim is available, use it to read man pages
if command -v nvim 1>/dev/null; then
  MANPAGER='nvim -c "set ft=man" -'
  export MANPAGER

## Otherwise, if vim is available, use it to read man pages
elif command -v vim 1>/dev/null; then
  MANPAGER='vim -M -c MANPAGER -'
  export MANPAGER

fi


# vim:ft=sh
