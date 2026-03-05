# zprofile: login shell initialization script
# Initialization script evaluation order:
# zshenv, zprofile, zshrc, zlogin
# see zsh(1)

# Load login shell config
if [[ -f ~/.profile && -r ~/.profile ]]; then
  . ~/.profile
fi

# Add zsh site-functions to FPATH
if [[ -d ~/.local/share/zsh/site-functions ]]; then
  FPATH="${FPATH:+${FPATH}:}${HOME}/.local/share/zsh/site-functions"
fi

# vi:ft=zsh
