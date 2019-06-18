## cnf.sh : command-not-found hooks


## bash
if test -n "${BASH-}"; then
  command_not_found_handle() {
    local - && set +e
    if command -v cnf-lookup 1>/dev/null; then
      if test -t 1; then
        cnf-lookup --colors -- "$1"
      else
        cnf-lookup -- "$1"
      fi
    elif test -x /usr/lib/command-not-found; then
      /usr/lib/command-not-found -- "$1"
    elif test -x /usr/share/command-not-found/command-not-found; then
      /usr/share/command-not-found/command-not-found -- "$1"
    else
      printf '%q: command not found\n' "$1"
    fi 1>&2
    return 127
  }
fi


## zsh
if test -n "${ZSH_NAME-}"; then
  command_not_found_handler() { 
    local - && set +e
    if command -v cnf-lookup 1>/dev/null; then
      if test -t 1; then
        cnf-lookup --colors -- "$1"
      else
        cnf-lookup -- "$1"
      fi
    elif test -x /usr/lib/command-not-found; then
      /usr/lib/command-not-found -- "$1"
    elif test -x /usr/share/command-not-found/command-not-found; then
      /usr/share/command-not-found/command-not-found -- "$1"
    else
      printf '%q: command not found\n' "$1"
    fi 1>&2
    return 127
  }
fi
