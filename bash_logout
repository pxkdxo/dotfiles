## ~/.bash_logout : bash logout script

## Honor both 'histappend' and 'erasedups'
if [[ :${HISTCONTROL-}: = *:erasedups:* ]]; then
  if [[ :${BASHOPTS-}:  = *:histappend:* ]]; then
    history -a  ## Append new history
    history -c  ## Clear history
    history -r  ## Read history (shared state)
  else
    history -n            ## Read new history
    shopt -s histappend   ## Enable 'histappend' (shared state)
  fi

  ## Clear the history buffer
  history -c

  ## Re-read history from updated histfile
  history -r
fi



## If leaving the console, clear the screen
if [[ ${SHLVL} -eq 1 ]]; then
  clear_console -q
## Otherwise, reset the terminal
else
  tput reset
fi
