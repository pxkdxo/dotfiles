## ~/.bash_logout : sourced upon exiting a login shell

## Update the history file
shopt -q histappend && {
  history -n
  history -w
  history -c
}

tput -S << @EOF
clear
reset
@EOF
