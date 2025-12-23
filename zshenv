# zshenv: zsh user global initialization script
# Initialization script evaluation order:
# zshenv, zprofile, zshrc, zlogin
# see zsh(1)

# Load ~/.env if it exists (before profile.d scripts)
if [[ -f ~/.env && -r ~/.env ]]; then
  emulate sh -c '. ~/.env'
fi

# Note: PAGER, EDITOR, VISUAL, and BROWSER are configured in profile.d/
# (pager.sh, editor.sh) to avoid duplication and ensure consistency.
# These are loaded via ~/.profile which is sourced in zprofile.

# vi:ft=zsh
