# zlogin: final initialization script for zsh login shells

# Import the systemd user environment into the shell
#() {
#  emulate -LR zsh
#  while IFS='=' read -r 'argv[1]' 'argv[2]'
#  do
#    [[ -v $1 ]] || export "$1=${(Q)2}"
#  done 2> /dev/null
#} < <(systemctl --user show-environment 2> /dev/null)

# Start an Xsession upon an login at tty1
if [[ $- == *i* && -z ${DISPLAY-} && ${XDG_VTNR} -eq 1 ]] && command -v startx >/dev/null
then
  exec startx
fi

# vi:ft=zsh
