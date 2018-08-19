## ~/.bash_profile : startup file for bash login-shells


## Load profile config
if [[ -f ~/.profile && -r ~/.profile ]]; then
  source ~/.profile
fi


## source config for interactive shells
if [[ -f ~/.bashrc && -r ~/.bashrc ]]; then
  source ~/.bashrc
fi


## autostart X upon login on tty1
if [[ -z ${DISPLAY} && ${XDG_VTNR} -eq 1 ]]; then
  exec /usr/bin/env startx
fi
