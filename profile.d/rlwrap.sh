## rlwrap.sh : configure rlwrap environment

case "${EDITOR##*/}" in

  emacs)
    RLWRAP_EDITOR="${EDITOR} +%L:%C %F"
    export RLWRAP_EDITOR
    ;;

  nvim|vim)
    RLWRAP_EDITOR="${EDITOR} -c 'call cursor(%L,%C)' %F"
    export RLWRAP_EDITOR
    ;;

  vi)
    RLWRAP_EDITOR="${EDITOR} -c %L %F"
    export RLWRAP_EDITOR
    ;;

  ?*)
    RLWRAP_EDITOR="${EDITOR} %F"
    export RLWRAP_EDITOR
    ;;

  *)
    unset -v RLWRAP_EDITOR
    ;;

esac
