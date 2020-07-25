# zprofile: login shell initialization script
# Initalization script evaluation order:
# zshenv, zprofile, zshrc, zlogin
# see zsh(1)


# Load login shell config
if [[ -f ~/.profile && -r ~/.profile ]]; then
  source ~/.profile
fi

# vi:ft=zsh
