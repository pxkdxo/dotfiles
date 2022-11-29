#!/usr/bin/env sh
# rlwrap.sh: configure the environment for rlwrap

# Set RLWRAP_EDITOR to based on the value of EDITOR
case "${EDITOR##*/}" in
  vim|[mn]vim)
    # shellcheck disable=SC2089
    export RLWRAP_EDITOR="${EDITOR} -c 'call cursor(%L,%C)' %F"
    ;;
  emacs)
    # shellcheck disable=SC2090
    export RLWRAP_EDITOR="${EDITOR} +%L:%C %F"
    ;;
  vi)
    export RLWRAP_EDITOR="${EDITOR} -c %L %F"
    ;;
esac

# vim:ft=sh
