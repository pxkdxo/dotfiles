## ~/.bash_logout : bash logout script
  
## Honor both 'histappend' and 'erasedups' by performing each manually
## Note: 'erasedups' only erases duplicates in histfile on write
if [[ :${HISTCONTROL}: = *:erasedups:* ]]; then
  if [[ :${BASHOPTS}:  = *:histappend:* ]]; then
    history -a  # Append new history
    history -c  # Clear history
    history -r  # Read history (shared state)
  else
    history -n            # Read new history
    shopt -s histappend   # Enable 'histappend' (shared state)
  fi

  ## Trigger duplicate removal by writing the history file 
  history -w

  ## No more history to append...
  history -c
fi

## Clear and reset the terminal
command -pv tput 1>/dev/null &&
  command -p tput reset

## When leaving the console clear the screen
if test "$(( SHLVL ))" -eq 1; then
    command -pv clear_console 1>/dev/null &&
      command -p clear_console -q
fi
