# zlogin: final initialization script for zsh login shells

# Import the systemd user environment into the shell
#() {
#emulate -L zsh
#while IFS='=' read -r 'argv[1]' 'argv[2]'
#do
#  if [[ -v $1 ]]
#  then systemctl --user set-environment "$1=${(P)2}"
#  else export "$1=${(Q)2}"
#  fi
#done 2> /dev/null
#} << STOP
#$(systemctl --user show-environment 2> /dev/null)
#STOP

# Start an Xsession upon an initial console login at tty1
if [[ -z ${DISPLAY-} ]] && (( XDG_VTNR == 1 )) && command -v startx > /dev/null
then exec startx
fi

# vi:ft=zsh
