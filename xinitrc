#!/usr/bin/env sh

## xinitrc : Initialize a new Xsession
## maintained by Patrick DeYoreo


## Clear resource database
command -p xrdb -load '/dev/null'


## merge in system resources
if test -f '/etc/X11/xinit/Xresources'; then
  command -p xrdb -merge '/etc/X11/xinit/Xresources'
fi


## run system scripts
if test -d '/etc/X11/xinit/xinitrc.d'; then
  for _ in '/etc/X11/xinit/xinitrc.d'/*; do
    if test -f "$_" && test -r "$_"; then
      . "$_"
    fi
  done
fi


## merge in user resources
if test -f "${HOME}/.Xresources"; then
  command -p xrdb -merge "${HOME}/.Xresources"
fi


## run user scripts
if test -d "${HOME}/.xinitrc.d"; then
  for _ in "${HOME}/.xinitrc.d"/*.sh; do
    if test -f "$_" && test -r "$_"; then
      . "$_"
    fi
  done
fi


## activate monitors
command -p xrandr --auto


## pass control to a window manager
exec awesome
