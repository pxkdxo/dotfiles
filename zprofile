# zprofile: login shell initialization script
# Initialization script evaluation order:
# zshenv, zprofile, zshrc, zlogin
# see zsh(1)

# Load login shell config under sh emulation: profile.d is POSIX sh, and a
# native-zsh NOMATCH on an unmatched glob would abort the sourced file.
if [[ -f ~/.profile && -r ~/.profile ]]; then
  emulate sh -c '. ~/.profile'
fi

# Add zsh site-functions to FPATH
if [[ -d ~/.local/share/zsh/site-functions ]]; then
  FPATH="${FPATH:+${FPATH}:}${HOME}/.local/share/zsh/site-functions"
fi

# vi:ft=zsh
