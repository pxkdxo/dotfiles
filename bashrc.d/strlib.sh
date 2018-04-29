## print uppercase version of each arg
function str::caseup() { printf '%s\n' "${@^^}"; }
function str::ccaseup() { printf '%s\n' "${@^}"; }

## print lowercase version of each arg
function str::casedn() { printf '%s\n' "${@,,}"; }
function str::ccasedn() { printf '%s\n' "${@,}"; }

## print inversecase version of each arg
function str::caseinv() { printf '%s\n' "${@~~}"; }
function str::ccaseinv() { printf '%s\n' "${@~}"; }

## print ascii values of given characters
function str::ord() { printf '%d\n' "${@/#/\'}"; }

## print characters of given ascii values
function str::chr() { printf '%b\n' $(printf '\%03o\n' "$@"); }

## print the prompt expansion of each arg
function str::promptex() { printf '%s\n' "${@@P}"; }
