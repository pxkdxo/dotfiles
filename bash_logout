#
## ~/.bash_logout
#

## save output of hash builtin
command -p mkdir -p "${XDG_DATA_HOME:-"${HOME}"/.local/share}"/bash/hash &&
  command -p hash >\
  "${XDG_DATA_HOME:-"${HOME}"/.local/share}"/bash/hash/"$(command -p date +\%s)"

## clear and reset the terminal
command -p tput -S <<\@EOF
clear
reset
@EOF
