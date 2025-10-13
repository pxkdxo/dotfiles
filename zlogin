# zlogin: final initialization script for zsh login shells
# Initalization script evaluation order:
# zshenv, zprofile, zshrc, zlogin
# see zsh(1)

# Make Ctrl-S/Ctrl-Q usable in terminals by disabling XON/XOFF flow control
stty -ixon -ixoff 2>/dev/null

# vi:ft=zsh
