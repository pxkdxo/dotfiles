#!/usr/bin/env sh
#
# rlwrap.sh: configure RLWRAP_EDITOR based on the setting of EDITOR

if test -n "${EDITOR:-}"; then
  case "${EDITOR##*/}" in
    vim|[mn]vim)
      # shellcheck disable=SC2089
      export RLWRAP_EDITOR="${EDITOR} -c 'call cursor(%L,%C)' %F"
      ;;
    emacs*)
      # shellcheck disable=SC2090
      export RLWRAP_EDITOR="${EDITOR} +%L:%C %F"
      ;;
    vi*)
      export RLWRAP_EDITOR="${EDITOR} -c %L %F"
      ;;
  esac
fi

# vim:ft=sh
