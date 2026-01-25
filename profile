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
    tput init
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
if test -d ~/.local/share/homebrew/bin
then
    path_prepend ~/.local/share/homebrew/bin
fi
if test -d ~/.local/opt/homebrew/bin
then
    path_prepend ~/.local/opt/homebrew/bin
fi
if test -d ~/.local
then
  path_prepend ~/.local/bin
fi

# Quick detour for early homebrew initialization
if command -v brew > /dev/null
then
  eval "$(brew shellenv)"
fi

# Load additional profile config
for profile in "${XDG_CONFIG_HOME:-${HOME}/.config}/profile.d"/*.sh; do
  if test -f "${profile}" && test -r "${profile}"; then
    . "${profile}"
  fi
done
unset profile


# vi:ft=sh
