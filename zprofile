# zprofile: login shell initialization script
# Initialization script evaluation order:
# zshenv, zprofile, zshrc, zlogin
# see zsh(1)

# Load login shell config. Source under sh emulation: profile.d scripts are
# POSIX sh and rely on sh semantics -- under native zsh an unmatched glob
# (e.g. ~/Library/Python/*/bin in 60-macos.sh on a bare Mac) raises NOMATCH
# and aborts the rest of the sourced file instead of staying literal.
if [[ -f ~/.profile && -r ~/.profile ]]; then
  emulate sh -c '. ~/.profile'
fi

# Add zsh site-functions to FPATH
if [[ -d ~/.local/share/zsh/site-functions ]]; then
  FPATH="${FPATH:+${FPATH}:}${HOME}/.local/share/zsh/site-functions"
fi

# vi:ft=zsh
