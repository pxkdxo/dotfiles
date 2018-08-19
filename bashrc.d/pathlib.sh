## A library to manipulate the PATH
## maintained by Patrick DeYoreo


PATH::append() {
  PATH=":${PATH}:"
  while test "$#" -gt 0; do
    if test -n "$1"; then
      case "${PATH}" in
        *:"$1":*)
          ;;
        *)
          PATH="${PATH:+"${PATH}:"}$1"
          ;;
      esac
    fi
    shift
  done
  PATH="${PATH:1:(-1)}"
}



PATH::prepend() {
  PATH=":${PATH}:"
  while test "$#" -gt 0; do
    if test -n "$1"; then
      case "${PATH}" in
        *:"$1":*)
          ;;
        *)
          PATH="$1${PATH:+":${PATH}"}"
          ;;
      esac
    fi
    shift
  done
  PATH="${PATH:1:(-1)}"
}



PATH::remove() {
  PATH=":${PATH}:"
  while test "$#" -gt 0; do
    if test -n "$1"; then
      while
        case "${PATH}" in
        *:"$1":*)
          PATH="${PATH%%:"$1":*}:${PATH#*:"$1":}" 
          ;;
        *)
          false
          ;;
      esac
      do :
      done
    fi
    shift
  done
  PATH="${PATH:1:(-1)}"
}
