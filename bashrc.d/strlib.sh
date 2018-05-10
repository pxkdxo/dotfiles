#
## collection of string-manipulation functions
#

## print uppercase version of each arg
str::case_up() { printf '%s\n' "${@^^}"; }
str::ccase_up() { printf '%s\n' "${@^}"; }

## print lowercase version of each arg
str::case_dn() { printf '%s\n' "${@,,}"; }
str::ccase_dn() { printf '%s\n' "${@,}"; }

## print inversecase version of each arg
str::case_in() { printf '%s\n' "${@~~}"; }
str::ccase_in() { printf '%s\n' "${@~}"; }


## print values of given chars
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


## print the prompt expansion of each arg
str::promptexpand() { printf '%s\n' "${@@P}"; }



# vim:ft=sh:tw=80
