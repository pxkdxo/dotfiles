# zlogout: zsh logout script

# Reset the terminal
if command -v tput > /dev/null
then
  tput reset
fi

# If leaving console, clear the screen
if (( SHLVL == 1 )) && command -v clear_console > /dev/null
then
  clear_console -q
fi

# vi:ft=zsh
