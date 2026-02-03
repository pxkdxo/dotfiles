# ~/.profile: login shell initialization script
# see bash(1), dash(1), sh(1), zsh(1), ...
# shellcheck shell=dash


# Termcap is outdated, old, and crusty, kill it.
unset TERMCAP


# Man is much better than us at figuring this out
unset MANPATH


# Initialize tty, and make <C-s>/<C-z> usable by disabling XON/XOFF
test -t 1 && { tput init && stty -ixon -ixoff; } 2>/dev/null || true


# Set file creation mode mask
# EUID is not defined in dash(1)
# shellcheck disable=SC3028
if test "${EUID:-$(id -u)}" -eq 0; then
  umask 0002
else
  umask 0022
fi


# path_print - Print the value of PATH with a chosen separator
# Description: Returns 0 if DIRECTORY is in PATH, 1 otherwise.
# Usage: path_print [DELIMITER]
# Positional Parameters:
#   DELIMITER: separator to use between elements - the empty string
#         will be understood to mean a null byte (default: newline)
path_print() {
  if test "$#" -gt 1; then
    >&2 printf 'usage: path_print [DELIMITER]\n'
    return 2
  fi
  if test -z "${PATH-}"; then
    return 0
  fi
  set -- "${1-\\n}" "${PATH:+${PATH}:}"
  printf '%s' "${2%%:*}"
  while set -- "$1" "${2#*:}" && test -n "$2"; do
    printf '%b%s' "${1:-\\x00}" "${2%%:*}"
  done
  if test "$1" != "\\n"; then
    echo
  fi
}


# path_contains - Check if an element is in PATH
# Description: Returns 0 if DIRECTORY is in PATH and 1 otherwise.
# Usage: path_contains DIRECTORY
# Positional Parameters:
#   DIRECTORY: element to check for
path_contains() {
  if test "$#" -ne 1; then
    >&2 printf 'usage: path_contains DIRECTORY\n'
    return 2
  fi
  case ":${PATH-}:" in
    *":$1:"*) return 0
      ;;
  esac
  return 1
}


# path_add - Add an element to PATH
# Description: Add DIRECTORY to PATH if it is not already there.
# Usage: path_add DIRECTORY
# Positional Parameters:
#   DIRECTORY: element to check for
path_add() {
  if test "$#" -ne 1; then
    >&2 printf 'usage: path_add DIRECTORY\n'
    return 2
  fi
  case ":${PATH-}:" in
    *":$1:"*) return 0
      ;;
    *) export PATH="${PATH:+${PATH}:}$1"
      ;;
  esac
}


# path_discard - Remove an element from PATH
# Description: Remove all occurrences of DIRECTORY from PATH.
# Usage: path_discard DIRECTORY
# Positional Parameters:
#   DIRECTORY: element to remove from PATH
path_discard() {
  if test "$#" -ne 1; then
    >&2 printf 'usage: path_discard DIRECTORY\n'
    return 2
  fi
  while path_contains "$1"; do
    set -- "$1" ":${PATH}:"
    set -- "$1" "${2%%:"${1}":*}" "${2#*:"${1}":}"
    set -- "$1" "${2#:}" "${3%:}"
    export PATH="${2}${3:+${2:+:}$3}"
  done
}


# path_append - Append an element to the end of PATH
# Description: Append DIRECTORY to the end of PATH and remove all other occurrences.
# Usage: path_append DIRECTORY
# Positional Parameters:
#   DIRECTORY: element to add to PATH
path_append() {
  if test "$#" -ne 1; then
    >&2 printf 'usage: path_append DIRECTORY\n'
    return 2
  fi
  path_discard "$1"
  export PATH="${PATH:+${PATH}:$1}"
}


# path_push - Push an element to the front of PATH
# Description: Push DIRECTORY to the front of PATH and remove any other occurrences.
# Usage: path_push DIRECTORY
# Positional Parameters:
#   DIRECTORY: element to add to PATH
path_push() {
  if test "$#" -lt 1; then
    >&2 printf 'usage: path_push DIRECTORY ...\n'
    return 2
  fi
  path_discard "$1"
  export PATH="${PATH:+$1:${PATH}}"
}


# path_insert - Insert an element into PATH at a given position
# Description:
#   Remove all occurrences of DIRECTORY from PATH, then insert at the specified index.
# Usage: path_insert DIRECTORY [INDEX|'#']
# positional parameters:
#   DIRECTORY: element to add to PATH
#   INDEX: target index at which to insert DIRECTORY to retrieve - can be positive (from front),
#       or negative (from rear), or the special character '#' to append to the end (* default: 0 *)
path_insert() {
  if test "$#" -eq 1; then
    path_push "$1"
  elif test "$#" -eq 2; then
    if test "$2" = "#"; then
      path_append "$1"
    elif { set -- "$1" "$(($2))"; } 2> /dev/null; then
      if test "$2" -eq 0; then
        path_push "$1"
      else
        path_discard "$1"
        case "$2" in
          -*)
            set -- "$1" "$2" "${PATH:+:${PATH}}" ""
            while test -n "$3" && test "$2" -ne 0; do
              set -- "$1" "$(($2 + 1))" "${3%:*}" "${3##*:}${4:+:$4}"
            done
            path_discard "$1"
            PATH="${3#:}" && export PATH="${PATH:+${PATH}:}$1${4:+:$4}"
            ;;
          *)
            path_discard "$1"
            set -- "$1" "$2" "" "${PATH:+${PATH}:}"
            while test -n "$4" && test "$2" -ne 0; do
              set -- "$1" "$(($2 + 1))" "${3:+$3:}${4%%:*}" "${4#*:}"
            done
            path_discard "$1"
            PATH="${4%:}" && export PATH="${3:+$3:}$1${PATH:+:${PATH}}"
            ;;
        esac
      fi
    else
      >&2 printf 'path_insert: expected an index, but got '\'%s\''\n' "$2"
      return 1
    fi
  else
    >&2 printf 'usage: path_insert DIRECTORY [INDEX|'\''#'\'']\n'
    return 2
  fi
}


path_push ~/.bin
path_push ~/.local/bin


# Load additional profile config
for profile in "${XDG_CONFIG_HOME:-${HOME}/.config}/profile.d"/*.sh; do
  if test -f "${profile}" && test -r "${profile}"; then
    . "${profile}"
  fi
done

path_push "${XDG_DATA_HOME:-${HOME}/.local/share}/homebrew/sbin"
path_push "${XDG_DATA_HOME:-${HOME}/.local/share}/homebrew/bin"

# One final detour for homebrew initialization
if command -v brew > /dev/null; then
  eval "$(brew shellenv)"
fi


# vi:ft=sh
