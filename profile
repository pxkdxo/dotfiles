# ~/.profile: login shell initialization script
# see bash(1), dash(1), sh(1), zsh(1), ...
# shellcheck shell=dash


# Termcap is outdated, old, and crusty, kill it.
unset TERMCAP


# Man is much better than us at figuring this out
unset MANPATH


# Initialize tty, and make <C-s>/<C-z> usable by disabling XON/XOFF
if test -t 1; then
  stty -ixon -ixoff || true
fi


# Set file creation mode mask
# EUID is not defined in POSIX
# shellcheck disable=SC3028
if test "${EUID:-$(id -u)}" -eq 0; then
  umask 0002
else
  umask 0022
fi


# path_print - Print PATH elements separated by newlines or a given string
# Description: Any backslash-escape sequences in SEPARATOR will be expanded.
# Usage: path_print [SEPARATOR]
# Positional Parameters:
#   SEPARATOR: separator to use between elements - the empty string will be
#              interpreted as a null byte (default: '\n')
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
  while set -- "${1:-\\000}" "${2#*:}" && test -n "$2"; do
    printf '%b%s' "$1" "${2%%:*}"
  done
  echo
}


# path_contains - Check if an element exists in PATH
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
    *":$1:"*) ;;
    *) return 1 ;;
  esac
}


# path_discard - Remove elements from PATH
# Description: Remove all occurrences of each DIRECTORY from PATH.
# Usage: path_discard DIRECTORY ...
# Positional Parameters:
#   DIRECTORY: an element to remove from PATH
path_discard() {
  if test "$#" -lt 1; then
    >&2 printf 'usage: path_discard DIRECTORY ...\n'
    return 2
  fi
  while test "$#" -gt 0; do
    while path_contains "$1"; do
      set -- ":${PATH}:" "$@"
      set -- "${1%%:"${2}":*}" "${1#*:"${2}":}" "$@"
      set -- "${1#:}" "${2%:}" "$@"
      export PATH="${1}${2:+${1:+:}$2}"
      shift 5
    done
    shift 1
  done
}


# path_append - Append each element to the end of PATH
# Description: Append each DIRECTORY to PATH and remove all other occurrences.
# Usage: path_append DIRECTORY ...
# Positional Parameters:
#   DIRECTORY: an element to add to PATH
path_append() {
  if test "$#" -lt 1; then
    >&2 printf 'usage: path_append DIRECTORY ...\n'
    return 2
  fi
  while test "$#" -gt 0; do
    path_discard "$1"
    export PATH="${PATH:+${PATH}:$1}"
    shift
  done
}


# path_push - Push each element to the front of PATH (LIFO)
# Description: Prepend each DIRECTORY to PATH and remove all other occurrences.
# Usage: path_push DIRECTORY ...
# Positional Parameters:
#   DIRECTORY: an element to add to PATH
path_push() {
  if test "$#" -lt 1; then
    >&2 printf 'usage: path_push DIRECTORY ...\n'
    return 2
  fi
  while test "$#" -gt 0; do
    path_discard "$1"
    export PATH="${PATH:+$1:${PATH}}"
    shift
  done
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


# Load additional profile config
for __profile__ in "${XDG_CONFIG_HOME:-${HOME}/.config}/profile.d"/*.sh; do
  if test -f "${__profile__}" && test -r "${__profile__}"; then
    . "${__profile__}"
  fi
done


# Make sure these are at the front
if test -d ~/.bin; then
  path_push ~/.bin
fi
if test -d ~/.local/bin; then
  path_push ~/.local/bin
fi
if test -d "${HOMEBREW_PREFIX-}"; then
  path_push "${HOMEBREW_PREFIX}/sbin"
  path_push "${HOMEBREW_PREFIX}/bin"
fi

# vi:ft=sh
