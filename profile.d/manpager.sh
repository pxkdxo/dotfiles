## manpager.sh : set MANPAGER

## If successfully unset ...
if unset -v MANPAGER; then

  ## If neovim is available ...
  if command -v nvim; then

    ## Use neovim to view man pages
    export MANPAGER="nvim -c 'set ft=man' -"

  fi 1>/dev/null

fi 2>/dev/null
