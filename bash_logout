# ~/.bash_logout : bash logout script
  
# Honor both 'histappend' and 'erasedups'
if [[ :${HISTCONTROL-}: = *:erasedups:* ]]; then
  if [[ :${BASHOPTS-}:  = *:histappend:* ]]; then
    history -a  # Append new history
    history -c  # Clear history
    history -r  # Read history (shared state)
  else
    history -n            # Read new history
    shopt -s histappend   # Enable 'histappend' (shared state)
  fi

  # Trigger duplicate removal by writing the history file 
  history -w

  # No more history to append...
  history -c
fi


# Clear and reset the terminal
tput reset


# When leaving the console clear the screen
if [[ ${SHLVL} -eq 1 ]]; then
  clear_console
fi
