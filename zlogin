#
## ~/.zlogin
#

## source profile config
test -f ~/.profile && test -r ~/.profile &&
  . ~/.profile

## source config for interactive shells
test -f ~/.zshrc && test -r ~/.zshrc &&
  . ~/.zshrc

## autostart X at login
test -z "${DISPLAY}" && test "${XDG_VTNR}" -eq 1 &&
  if test -f ~/.xinitrc && test -r ~/.xinitrc; then
    exec /usr/bin/env startx ~/.xinitrc
  else
    exec /usr/bin/env startx
  fi
