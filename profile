# ~/.profile: login shell initialization script
# see bash(1), dash(1), sh(1), zsh(1), ...

# Initialize terminal
if test -t 1; then
  # Initialize term
  if command -v tput 1> /dev/null; then
    tput init || true
  fi
  if command -v stty 1> /dev/null; then
    # Make Ctrl-S/Ctrl-Q usable in terminals by disabling XON/XOFF flow control
    stty -ixon -ixoff 2>/dev/null
  fi
fi

# Termcap is outdated, old, and crusty, kill it.
unset TERMCAP

# Man is much better than us at figuring this out
unset MANPATH

# Set file creation mode mask
if test "${UID:-$(id -u)}" -eq 0; then
  umask 0002
else
  umask 0022
fi

# Function to format messages to stderr
# usage: log -u FD -p PREFIX [--] MESSAGE [DETAIL] ...
log() {
  local OPTIND=1
  local OPTARG
  local option
  local fd=1
  local prefix=""
  local message=""
  while getopts ':u:p:' option; do
    case "${option}" in
      u)
        case "$((OPTARG))" in
          (*[![:digit:]]*) return 1 ;;
        esac
        fd="$((OPTARG))"
        ;;
      p)
        prefix="${OPTARG}"
        ;;
      \?)
        return 2
        ;;
      \:)
        return 2
        ;;
    esac
  done
  shift "$((OPTIND - 1))"
  while test "$#" -gt 0; do
    message="${message:+${message}: }$1"
    shift
  done
  printf '%s %s\n' "${prefix}" "${message}" >&"${fd}"
}

log_critical() {
  log -u 2 -p '[#:CRITICAL:#]:/#> ' "$@"
}

log_error() {
  log -u 2 -p '[!:ERROR:!]:/!> ' "$@"
}

log_warning() {
  log -p '[*:WARNING:*]:/*> ' "$@"
}

log_info() {
  log -p '[@:INFO:@]:/@> ' "$@"
}

log_debug() {
  log -p '[%:DEBUG:%]:/%> ' "$@"
}

# Function to run a command on each arg
# usage: map [--] COMMAND ARG ...
map() {
  local OPTIND=1
  local OPTARG
  while getopts ':' _; do :; done
  shift "$((OPTIND - 1))"
  local ARG0="$1"
  shift
  while test "$#" -gt 0; do
    "${ARG0}" "$1"
    shift
  done
}


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

# Function to insert an element in PATH
# usage: path_insert TO_ADD [0|%|^|-1|#|$]
path_insert() {
  if test "$#" -eq 1; then
    case ":${PATH}:" in
      *":$1:"*) ;;
      *) PATH="$1${PATH:+:${PATH}}" ;;
    esac
  elif test "$#" -eq 2; then
    case ":${PATH}:" in
      *":$1:"*) : ;;
      *)
        case "$2" in
          [#$])  PATH="${PATH:+${PATH}:}$1" ;;
          [%^])  PATH="$1${PATH:+:${PATH}}" ;;
          *)
            case "$(($2))" in
              -1) PATH="${PATH:+${PATH}:}$1" ;;
              0) PATH="$1${PATH:+:${PATH}}" ;;
              *) return 1 ;;
            esac
            ;;
        esac
        ;;
    esac
  else
    >&2 printf '%s: usage: path_insert TO_ADD [0|%|^|-1|#|$]\n' "${0##*/}"
      return 2
  fi
}


# Function to check if a command exists
command_exists() {
  command -v "$1" > /dev/null 2>&1
}

# Function to source a file if it exists and is readable
source_if() {
  if test -r "$1"; then
    . "$1"
    return 0
  fi
  return 1
}

# Prepend executable paths
for dir in ~/.bin ~/.local/bin; do
  if test -d "${dir}"; then
    path_insert "${dir}"
  fi
done
unset dir

# Load additional profile config
if test -d "${HOME}/.profile.d/"; then
  for file in "${HOME}/.profile.d"/*.sh; do
    if test -r "${file}"; then
      . "${file}"
    fi
  done 2>/dev/null
fi
# vi:ft=sh
