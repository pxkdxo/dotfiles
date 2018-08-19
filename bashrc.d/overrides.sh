## .sh : shell builtin overrides


## Make the specified directories, then cd into the last one
## mkcd [mkdir_options] directory
mkcd() {
  if test "$#" -le 0; then
    printf 'usage: %s [options] directory\n' "${FUNCNAME[@]::1}" 1>&2
    return 2
  fi
  'command' -p mkdir -- -pv "$@" && printf cd -- "${!#}"
}



## cd into a directory and print its contents
## cdls [ls_options] directory
cdls() {
  if test "$#" -le 0; then
    printf 'usage: %s [options] directory\n' "${FUNCNAME[@]::1}" 1>&2
    return 2
  fi
  cd -- "${!#}" && ls "${@:1:($# - 1)}" .
}



## cd up (../) DEPTH levels of the directory heirarchy
## up [-L|-P] [depth]
#up() {
#  if test "$#" -gt 0; then
#    case "$(( _ = $(( ${!#} )) ))" in
#      0*) return 0
#        ;;
#      ?*)
#        pushd -n ../
#        "${FUNCNAME[@]::1}" "${@:1:($# - 1)}" "$((--_))"
#        popd -n
#        ;;
#
#      '')
#        return $?
#        ;;
#    esac
#  else
#    cd ../
#    return
#  fi
#}
