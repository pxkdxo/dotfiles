## ~/.profile.d/manpager.sh : define the manual pager

## If Vim is available...
if command -v vim; then

  ## Use Vim to view manual pages
  export MANPAGER="vim -M -c 'setlocal cc= nonu nornu' -c MANPAGER -"

fi 1>/dev/null 2>&1
