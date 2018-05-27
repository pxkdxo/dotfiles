## cnf.sh : command-not-found hooks

## bash
command_not_found_handle() {
  { command -v cnf-lookup 1>/dev/null &&
    if test -t 1; then
      cnf-lookup --colors -- "$1"
    else
      cnf-lookup -- "$1"
    fi || printf '%q: %q: command not found\n' "${0##*/}" "$1"
  } 1>&2
  return 127
}


## zsh
command_not_found_handler() { 
  { command -v cnf-lookup 1>/dev/null &&
    if test -t 1; then
      cnf-lookup --colors -- "$1"
    else
      cnf-lookup -- "$1"
    fi || printf '%q: %q: command not found\n' "${0##*/}" "$1"
  } 1>&2
  return 127
}
