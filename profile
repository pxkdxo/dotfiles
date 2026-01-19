# ~/.profile: login shell initialization script
# see bash(1), dash(1), sh(1), zsh(1), ...

# Termcap is outdated, old, and crusty, kill it.
unset TERMCAP

# Man is much better than us at figuring this out
unset MANPATH

# Initialize terminal
if test -t 1; then
  # Make Ctrl-S/Ctrl-Q usable in terminals by disabling XON/XOFF flow control
  if command -v stty 1> /dev/null; then
    stty -ixon -ixoff 2>/dev/null
  fi
  # Initialize terminal
  if command -v tput 1> /dev/null; then
    tput init || true
  fi
fi

# Set file creation mode mask
if test "${UID:-$(id -u)}" -eq 0; then
  umask 0002
else
  umask 0022
fi


# Function to append an element to PATH
# usage: path_append TO_ADD
path_append() {
  if test "$#" -eq 1; then
    case ":${PATH}:" in
      *":$1:"*) ;;
      *) PATH="${PATH:+${PATH}:}$1" ;;
    esac
  else
    >&2 printf '%s: usage: path_append TO_ADD\n' "${0##*/}"
    return 2
  fi
}


# Function to prepend an element to PATH
# usage: path_prepend TO_ADD
path_prepend() {
  if test "$#" -eq 1; then
    case ":${PATH}:" in
      *":$1:"*) ;;
      *) PATH="$1${PATH:+:${PATH}}" ;;
    esac
  else
    >&2 printf '%s: usage: path_prepend TO_ADD\n' "${0##*/}"
    return 2
  fi
}


# Prepend executable paths
for dir in ~/.local/share/homebrew/bin ~/.local/opt/homebrew/bin  ~/.local/bin; do
  if test -d "${dir}"; then
    path_prepend "${dir}"
  fi
done
unset dir


# Quick detour for homebrew initialization
if command -v brew > /dev/null
then
  eval "$(brew shellenv)"
fi


# Load additional profile config
if test -d "${XDG_CONFIG_HOME:-${HOME}/.config}/profile.d"; then
  dir="${XDG_CONFIG_HOME:-${HOME}/.config}/profile.d"
else
  dir="${HOME}/.profile.d"
fi
for file in "${dir}"/*.sh; do
  if test -r "${file}"; then
    . "${file}"
  fi
done
unset dir
unset file


# vi:ft=sh

. "$HOME/.local/share/../bin/env"
