#!/usr/bin/env sh

## xinitrc : Initialize a new Xsession


## Clear X resource database
xrdb -load '/dev/null'

## Merge in system resources
xrdb -merge '/etc/X11/xinit/Xresources'


## run system scripts
if test -d '/etc/X11/xinit/xinitrc.d'; then
  for _ in '/etc/X11/xinit/xinitrc.d'/*; do
    if test -f "$_" && test -r "$_"; then
      . "$_"
    fi
  done
fi


## Merge in user resources
xrdb -merge "${HOME}/.Xresources"

## run user scripts
if test -d "${HOME}/.xinitrc.d"; then
  for _ in "${HOME}/.xinitrc.d"/*.sh; do
    if test -f "$_" && test -r "$_"; then
      . "$_"
    fi
  done
fi


## Activate monitors
xrandr --auto

## Pass control to WM
exec awesome
