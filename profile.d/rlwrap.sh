## rlwrap.sh : configure the environment for rlwrap

## Set RLWRAP_EDITOR to based on the value of EDITOR
case "${EDITOR##*/}" in
  vim|[mn]vim)
    export RLWRAP_EDITOR="${EDITOR} -c 'call cursor(%L,%C)' %F"
    ;;
  emacs)
    export RLWRAP_EDITOR="${EDITOR} +%L:%C %F"
    ;;
  vi)
    export RLWRAP_EDITOR="${EDITOR} -c %L %F"
    ;;
esac

# vim:ft=sh
