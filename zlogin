# zlogin: final initialization script for zsh login shells
# Initialization script evaluation order:
# zshenv, zprofile, zshrc, zlogin
# see zsh(1)

# Only run in interactive login shells
if [[ -o login && -o interactive ]]; then
  # Make Ctrl-S/Ctrl-Q usable in terminals by disabling XON/XOFF flow control
  if command -v stty > /dev/null && [[ -t 0 ]]; then
    stty -ixon -ixoff 2>/dev/null || true
  fi
fi

# vi:ft=zsh
