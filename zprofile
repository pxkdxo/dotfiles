# zprofile: login shell initialization script
# Initalization script evaluation order:
# zshenv, zprofile, zshrc, zlogin
# see zsh(1)

# Load login shell config
if [[ -f ~/.profile && -r ~/.profile ]]; then
  emulate sh -c '. ~/.profile'
fi

# Load ~/.env
if [[ -f "${XDG_DATA_HOME:-${HOME}/.local/share}/env/env.sh" ]]; then
  emulate sh -c '. "${XDG_DATA_HOME:-${HOME}/.local/share}/env/env.sh"'
fi
if [[ -f ~/.env ]]; then
  emulate sh -c '. ~/.env'
fi

if [[ -d ~/.local/share/zsh ]]; then
  FPATH="${FPATH:+${FPATH}:}${HOME}/.local/share/zsh/site-functions"
fi

function command_not_found_handler() {
  if command -v cnf-lookup > /dev/null; then
    if test -t 1; then
      cnf-lookup --colors -- "${@::1}"
    else
      cnf-lookup -- "${@::1}"
    fi
  elif test -x ~/.local/lib/command-not-found; then
    ~/.local/lib/command-not-found --no-failure-msg -- "${@::1}"
  elif test -x /usr/local/lib/command-not-found; then
    /usr/local/lib/command-not-found --no-failure-msg -- "${@::1}"
  elif test -x /usr/lib/command-not-found; then
    /usr/lib/command-not-found --no-failure-msg -- "${@::1}"
  else
    printf '%s: command not found\n' "${@::1}"
  fi >&2
  return 127
}

# vi:ft=zsh
