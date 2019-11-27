# ~/.bash_logout: bash logout script

# Reset the terminal
if command -v tput > /dev/null
then
  tput reset
fi

# If leaving the console, clear the screen
if (( SHLVL == 1 ))
then
  clear_console -q
fi

# vi:ft=sh
