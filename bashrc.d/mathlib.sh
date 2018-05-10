##
## 20-mathlib: Collection of functions to do math in bash
##


function math::__accumulate() { 
  printf '%d\n' "$(("$*"))"
}

function math::multiply() {
    IFS='*' math::__accumulate "$@"
}

function math::divide() {
    IFS='/' math::__accumulate "$@"
}

function math::add() {
    IFS='+' math::__accumulate "$@"
}

function math::subtract() {
    IFS='-' math::__accumulate "$@"
}

function math::xor() {
    IFS='^' math::__accumulate "$@"
}

function math::and() {
    IFS='&' math::__accumulate "$@"
}

function math::or() {
    IFS='|' math::__accumulate "$@"
}
