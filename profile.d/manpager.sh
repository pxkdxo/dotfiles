## manpager.sh : set MANPAGER

## Set the command for viewing man pages
if unset -v MANPAGER; then

  ## Use neovim to view man pages
  if command -v nvim; then
    export MANPAGER='nvim -c '"'"'set ft=man'"'"' -'

#  ## Use vim to view man pages
#  elif command -v vim; then
#    export MANPAGER='env MAN_PN=1 vim -M -c '"'"'MANPAGER'"'"' -'

  fi 1>/dev/null

fi 2>/dev/null
