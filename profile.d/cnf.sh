#!/usr/bin/env sh
# cnf.sh: command-not-found hooks for bash and zsh

# bash definition
# shellcheck disable=SC2112
if test -n "${BASH}"; then
  command_not_found_handle() {
    if command -v cnf-lookup > /dev/null; then
      if test -t 1; then
        cnf-lookup --colors -- ${1+"$1"}
      else
        cnf-lookup -- ${1+"$1"}
      fi
    elif test -x ~/.local/lib/command-not-found; then
       ~/.local/lib/command-not-found --no-failure-msg -- ${1+"$1"}
    elif test -x /usr/local/lib/command-not-found; then
       /usr/local/lib/command-not-found --no-failure-msg -- ${1+"$1"}
    elif test -x /usr/lib/command-not-found; then
       /usr/lib/command-not-found --no-failure-msg -- ${1+"$1"}
    elif test -x /lib/command-not-found; then
       /lib/command-not-found --no-failure-msg -- ${1+"$1"}
    else
      printf '%s: command not found\n' ${1+"$1"}
    fi >&2
    return 127
  }
fi

# zsh definition
# shellcheck disable=SC2112
if test -n "${ZSH_NAME}"; then
  command_not_found_handler() {
    if command -v cnf-lookup > /dev/null; then
      if test -t 1; then
        cnf-lookup --colors -- ${1+"$1"}
      else
        cnf-lookup -- ${1+"$1"}
      fi
    elif test -x ~/.local/lib/command-not-found; then
       ~/.local/lib/command-not-found --no-failure-msg -- ${1+"$1"}
    elif test -x /usr/local/lib/command-not-found; then
       /usr/local/lib/command-not-found --no-failure-msg -- ${1+"$1"}
    elif test -x /usr/lib/command-not-found; then
       /usr/lib/command-not-found --no-failure-msg -- ${1+"$1"}
    elif test -x /lib/command-not-found; then
       /lib/command-not-found --no-failure-msg -- ${1+"$1"}
    else
      printf '%s: command not found\n' ${1+"$1"}
    fi >&2
    return 127
  }
fi

# vim:ft=sh
