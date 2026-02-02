# zlogout: user logout script
# Initalization script evaluation order:
# zshenv, zprofile, zshrc, zlogin
# see zsh(1)

# Reset and clean the terminal
{ tput reset || reset || { test "${SHLVL}" -le 1 && tput clear || clear; } || 2> /dev/null; } || true


# vi:ft=zsh
