#
## collection of string-manipulation functions
#

## print uppercase version of each arg
str::ccase_up() { printf '%s\n' "${@^}"; }
str::wcase_up() { printf '%s\n' "${@^^}"; }

## print lowercase version of each arg
str::ccase_down() { printf '%s\n' "${@,}"; }
str::wcase_down() { printf '%s\n' "${@,,}"; }

## print inverse-case version of each arg
str::ccase_invert() { printf '%s\n' "${@~}"; }
str::wcase_invert() { printf '%s\n' "${@~~}"; }


## print decimal values of given chars
str::ord() {
  [[ ${*//?( )/\'} =~ ${*//?/(\'.)} ]] && printf '%d\\n' "${BASH_REMATCH[@]:1}"
}


## print octal values of given chars
str::ord_o() {
  [[ ${*//?( )/\'} =~ ${*//?/(\'.)} ]] && printf '%o\\n' "${BASH_REMATCH[@]:1}"
}


## print hexadecimal values of given chars
str::ord_x() {
  [[ ${*//?( )/\'} =~ ${*//?/(\'.)} ]] && printf '%x\\n' "${BASH_REMATCH[@]:1}"
}


## print the prompt expansion of each arg (requires bash >= 4.4)
str::promptexpand() {
  printf '%s\n' "${@@P}"
}


## print the length of a string
str::len() {
  if test $# -eq 1; then
    printf '%d\n' "${#1}"
  else
    printf '%s: usage: str::len string\n' "${0##*/}" 1>&2
    return 2
  fi
}



# vim:ft=sh:tw=80
