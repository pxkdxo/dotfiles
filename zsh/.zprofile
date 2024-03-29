# zprofile: login shell initialization script
# Initalization script evaluation order:
# zshenv, zprofile, zshrc, zlogin
# see zsh(1)

# Load login shell config
if [[ -f ~/.profile && -r ~/.profile ]]; then
  source ~/.profile
fi

# Load homebrew
if [[ -f /opt/homebrew/bin/brew && -x /opt/homebrew/bin/brew ]]
then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# vi:ft=zsh
