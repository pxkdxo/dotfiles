# ~/.profile: login shell initialization script
# see bash(1), dash(1), sh(1), zsh(1), ...

# Initialize terminal
if test -t 1; then
  if command -v tput 1> /dev/null; then
    tput init
  fi
  if command -v stty 1> /dev/null; then
    stty start '^-' stop '^-'
  fi
fi

# Set file creation mode mask
if test "${UID:-$(id -u)}" -eq 0; then
  umask 0002
else
  umask 0022
fi

# Prepend executable paths
if test -d "${HOME}/.bin"; then
  case ":${PATH}:" in
    *:"${HOME}/.bin":*) ;;
    *) export PATH="${HOME}/.bin${PATH:+:${PATH}}" ;;
  esac
fi
if test -d "${HOME}/.local/bin"; then
  case ":${PATH}:" in
    *:"${HOME}/.local/bin":*) ;;
    *) export PATH="${HOME}/.local/bin${PATH:+:${PATH}}" ;;
  esac
fi
 
# Load additional profile config
if test -d "${HOME}/.profile.d"; then
  for name in "${HOME}/.profile.d"/*.sh; do
    if test -f "${name}" && test -r "${name}"; then
      . "${name}"
    fi
  done
fi
unset -v name


# vi:ft=sh
