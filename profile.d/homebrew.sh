if test -d "${HOMEBREW_HOME:-}"
then
  eval "$("${HOMEBREW_HOME:-}/bin/brew" shellenv)"
elif test -d "${XDG_DATA_HOME:-"${HOME}/.local/share"}/homebrew"
then
  eval "$("${XDG_DATA_HOME:-"${HOME}/.local/share"}/homebrew/bin/brew" shellenv)"
elif test -d ~/.local/opt/homebrew
then
  eval "$(~/.local/opt/homebrew/bin/brew shellenv)"
elif test -d ~/.homebrew
then
  eval "$(~/.homebrew/bin/brew shellenv)"
elif test -d ~/homebrew
then
  eval "$(~/homebrew/bin/brew shellenv)"
fi
