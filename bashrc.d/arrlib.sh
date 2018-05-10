##
## 20-arrlib : Library of functions to manipulate bash arrays
##


function arr::join() {
  [[ $## -eq 2 && $1 = [[:alpha:]_]*([[:alnum:]_]) ]] || return 2
  trap 'printf '"'"'%s\n'"'"' "${'"${1%%:*}[*]${1##"${1%%:*}"}"'}";'"$(
  if [[ $(trap -p RETURN) ]]; then
    printf '%s' "$(trap -p RETURN)"
  else
    printf 'trap -- RETURN'
  fi)" RETURN
  IFS=$2 return
} && declare -ft arr::join



function arr::ifsjoin() {
  [[ $## -eq 1 && $1 = [[:alpha:]_]*([[:alnum:]_]) ]] || return 2
  trap 'printf '"'"'%s\n'"'"' "${'"${1%%:*}[*]${1##"${1%%:*}"}"'}";'"$(
  if [[ $(trap -p RETURN) ]]; then
    printf '%s' "$(trap -p RETURN)"
  else
    printf 'trap -- RETURN'
  fi)" RETURN
  return
} && declare -ft arr::ifsjoin
