# ~/.bash_logout: bash logout script

# Reset the terminal
tput reset

# If leaving the console, clear the screen
if (( SHLVL ))
then
    clear_console -q
fi


# vi:ft=sh
