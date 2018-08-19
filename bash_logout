## ~/.bash_logout : bash logout script
  
## Respect histappend and erasedups by processing the history to a common state
if [[ :${HISTCONTROL}: = *:erasedups:* ]]; then
  if [[ :${BASHOPTS}:  = *:histappend:* ]]; then
    history -a
    history -c
    history -r
  else
    history -n
    shopt -s histappend
  fi

  ## Now trigger duplicate removal by writing the history file 
  history -w

  ## No more history to append..
  history -c
fi

## Clear and reset the terminal
tput reset
