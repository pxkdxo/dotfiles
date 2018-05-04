#
## ~/.bash_profile
#

## source profile config
if test -f ~/.profile && test -r ~/.profile; then
  . ~/.profile
fi

## source config for interactive shells
if test -f ~/.bashrc && test -r ~/.bashrc; then
  . ~/.bashrc
fi

## autostart X at login
if test -z "${DISPLAY}" && test "${XDG_VTNR}" -eq 1; then
  if test -f ~/.xinitrc && test -r ~/.xinitrc; then
    exec /usr/bin/env startx ~/.xinitrc
  else
    exec /usr/bin/env startx
  fi
fi
