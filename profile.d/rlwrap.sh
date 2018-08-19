## rlwrap.sh : configure rlwrap environment

case "${EDITOR##*/}" in

  emacs)
    export RLWRAP_EDITOR="${EDITOR} +%L:%C %F"
    ;;

  nvim|vim)
    export RLWRAP_EDITOR="${EDITOR} -c 'call cursor(%L,%C)' %F"
    ;;

  vi)
    export RLWRAP_EDITOR="${EDITOR} -c %L %F"
    ;;

  ?*)
    export RLWRAP_EDITOR="${EDITOR} %F"
    ;;

  *)
    unset -v RLWRAP_EDITOR
    ;;

esac 2>/dev/null


