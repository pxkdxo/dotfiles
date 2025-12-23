#!/usr/bin/env sh
# rlwrap.sh: configure the environment for rlwrap

# Set RLWRAP_EDITOR based on the value of EDITOR
if test -n "${EDITOR:-}"; then
  editor_basename="${EDITOR##*/}"
  case "${editor_basename}" in
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
  unset editor_basename
fi

# vim:ft=sh
