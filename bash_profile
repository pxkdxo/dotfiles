#
## ~/.bash_profile
#

## source profile config
[[ -f ~/.profile ]] && . ~/.profile

## source config for interactive shells
[[ -f ~/.bashrc ]] && . ~/.bashrc

## autostart X at login
[[ ! -v DISPLAY ]] && (( XDG_VTNR == 1 )) && exec startx
