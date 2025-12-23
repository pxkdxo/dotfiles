# zprofile: login shell initialization script
# Initialization script evaluation order:
# zshenv, zprofile, zshrc, zlogin
# see zsh(1)

# Load login shell config
if [[ -f ~/.profile && -r ~/.profile ]]; then
  emulate sh -c '. ~/.profile'
fi

# Load environment files
if [[ -f "${XDG_DATA_HOME:-${HOME}/.local/share}/env/env.sh" ]]; then
  emulate sh -c '. "${XDG_DATA_HOME:-${HOME}/.local/share}/env/env.sh"'
elif [[ -f ~/.env ]]; then
  emulate sh -c '. ~/.env'
fi

# Add zsh site-functions to FPATH
if [[ -d ~/.local/share/zsh/site-functions ]]; then
  FPATH="${FPATH:+${FPATH}:}${HOME}/.local/share/zsh/site-functions"
fi

# Note: command_not_found_handler is defined in profile.d/cnf.sh
# to avoid duplication and ensure consistency across shells

# vi:ft=zsh
