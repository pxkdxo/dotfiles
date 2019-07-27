## rlwrap.sh : configure the environment for rlwrap


## If EDITOR is non-null, set RLWRAP_EDITOR to an appropriate value
if test -n "${EDITOR-}"; then
  case "${EDITOR##*/}" in
    vim|nvim)
      RLWRAP_EDITOR="${EDITOR} -c 'call cursor(%L,%C)' %F"
      export RLWRAP_EDITOR
      ;;
    emacs)
      RLWRAP_EDITOR="${EDITOR} +%L:%C %F"
      export RLWRAP_EDITOR
      ;;
    vi)
      RLWRAP_EDITOR="${EDITOR} -c %L %F"
      export RLWRAP_EDITOR
      ;;
  esac
fi


# vim:ft=sh
