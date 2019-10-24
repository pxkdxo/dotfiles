# ~/.bash_logout: bash logout script

# Reset the terminal
tput reset

# If leaving the console, clear the screen
if (( SHLVL == 1 ))
then
  clear_console -q
fi

# vi:ft=sh
