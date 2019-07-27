#
## ~/.bash_logout : bash logout script
###


### Honor both 'histappend' and 'erasedups'
if [[ :${BASHOPTS}::${HISTCONTROL}: == *:histappend:*:erasedups:* ]]; then
  history -n  ## Read new history
  history -w  ## Write history (erase duplicates)
  history -c  ## Clear history
fi


## If leaving the console, clear the screen; otherwise, reset the terminal
if (( SHLVL == 1 )); then
  clear_console -q
else
  tput reset
fi


# vi:ft=sh
