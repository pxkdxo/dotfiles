#
## ~/.bash_profile
#

## source profile config
if [[ -f ~/.profile ]]; then
  . ~/.profile
fi


## source config for interactive shells
if [[ -f ~/.bashrc ]]; then
  . ~/.bashrc
fi


## autostart X upon login on tty1
if [[ -z ${DISPLAY} && ${XDG_VTNR} -eq 1 ]]; then
  exec /usr/bin/env startx
fi
