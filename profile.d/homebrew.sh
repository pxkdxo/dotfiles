# Load homebrew
if test -d "${HOMEBREW_HOME:-}"
then
  eval "$("${HOMEBREW_HOME:-}/bin/brew" shellenv)"
elif test -d "${XDG_DATA_HOME:-"${HOME}/.local/share"}/homebrew"
then
  export HOMEBREW_HOME="${XDG_DATA_HOME:-"${HOME}/.local/share"}/homebrew"
  eval "$("${XDG_DATA_HOME:-"${HOME}/.local/share"}/homebrew/bin/brew" shellenv)"
elif test -d ~/.local/opt/homebrew
then
  export HOMEBREW_HOME="${HOME}/.local/opt/homebrew"
  eval "$(~/.local/opt/homebrew/bin/brew shellenv)"
elif test -d ~/.homebrew
then
  export HOMEBREW_HOME="${HOME}/.homebrew"
  eval "$(~/.homebrew/bin/brew shellenv)"
fi
