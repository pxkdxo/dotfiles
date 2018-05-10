##
## ~/.bash_profile
##

## source profile config
if test -f ~/.profile; then
  . ~/.profile
fi

## source config for interactive shells
if test -f ~/.bashrc; then
  . ~/.bashrc
fi

## autostart X upon login on tty1
if test -z "${DISPLAY}" && test "$((XDG_VTNR))" -eq 1; then
  exec /usr/bin/env startx
fi
