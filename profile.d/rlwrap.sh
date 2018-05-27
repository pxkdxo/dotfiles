## rlwrap.sh : configure environment for rlwrap


## If RLWRAP_EDITOR is non-null just export it
if test -n "${RLWRAP_EDITOR}"; then
  export RLWRAP_EDITOR

## Otherwise, if it's null or unset, set it
elif test -n "${EDITOR}"; then

  case "${EDITOR}" in

    emacs|*/emacs)
      export RLWRAP_EDITOR="${EDITOR} +%L:%C %F"
      ;;

    vi|*/vi)
      export RLWRAP_EDITOR="${EDITOR} -c %L %F"
      ;;

    vim|*/vim)
      export RLWRAP_EDITOR="${EDITOR} -c 'call cursor(%L,%C)' %F"
      ;;

    *)
      export RLWRAP_EDITOR="${EDITOR} %F"
      ;;

  esac

elif command -v vim; then
  export RLWRAP_EDITOR="vim -c 'call cursor(%L,%C)' %F"

elif command -v vi; then
  export RLWRAP_EDITOR="vi -c %L %F"

elif command -v nano; then
  export RLWRAP_EDITOR="nano %F"

fi 1>/dev/null

