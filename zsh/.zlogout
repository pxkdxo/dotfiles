# zlogout: user logout script
# Initalization script evaluation order:
# zshenv, zprofile, zshrc, zlogin
# see zsh(1)

# Reset the terminal
if command -v reset > /dev/null; then
  reset
fi

# If leaving console, clear the screen
# if (( SHLVL == 1 )) && command -v clear_console > /dev/null; then
#   clear_console -q
# fi

# vi:ft=zsh
