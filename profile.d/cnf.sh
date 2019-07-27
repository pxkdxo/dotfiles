## cnf.sh : command-not-found hooks for bash and zsh


## bash hook definition
if test -n "${BASH-}"; then
  command_not_found_handle() {
    local -
    set +e
    if command -v cnf-lookup 1>/dev/null; then
      if test -t 1; then
        cnf-lookup --colors -- "${1-}"
      else
        cnf-lookup -- "${1-}"
      fi
    elif test -x /usr/lib/command-not-found; then
      /usr/lib/command-not-found -- "${1-}"
    else
      printf '%s: command not found\n' "${1-}"
    fi 1>&2
    return 127
  }
fi


## zsh hook definition
if test -n "${ZSH_NAME-}"; then
  command_not_found_handler() { 
    local -
    set +e
    if command -v cnf-lookup 1>/dev/null; then
      if test -t 1; then
        cnf-lookup --colors -- "${1-}"
      else
        cnf-lookup -- "${1-}"
      fi
    elif test -x /usr/lib/command-not-found; then
      /usr/lib/command-not-found -- "${1-}"
    else
      printf '%s: command not found\n' "${1-}"
    fi 1>&2
    return 127
  }
fi


# vim:ft=sh
