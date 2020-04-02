# zshenv: first user initialization script for all zsh shells

NULLCMD='cat'
if [[ -z ${PAGER} ]]
then
  if command -v pager
  then
    READNULLCMD='pager'
  elif command -v bat
  then
    READNULLCMD='bat --paging=always'
  elif command -v vimpager
  then
    READNULLCMD='vimpager'
  elif command -v less
  then
    READNULLCMD='less'
  else
    READNULLCMD='cat'
  fi > /dev/null
else
  READNULLCMD="${PAGER}"
fi

# vi:ft=zsh
