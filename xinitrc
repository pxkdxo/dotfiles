#!/usr/bin/env bash

##
## Initialize a new Xsession
##

## Clear resource database
xrdb -load /dev/null

## merge in system resources
if test -f '/etc/X11/xinit/Xresources'; then
  xrdb -merge '/etc/X11/xinit/Xresources'
fi

## run system scripts
if test -d '/etc/X11/xinit/xinitrc.d/' && test -r /etc/X11/xinitrc.d/; then
  for _ in '/etc/X11/xinit/xinitrc.d'/*; do
    if test -f "$_" && test -r "$_"; then
      -. "$_"
    fi
  done
fi

## merge in user resources
if test -f "${HOME}/.Xresources"; then
  xrdb -merge "${HOME}/.Xresources"
fi

## run user scripts
if test -d "${HOME}/.xinitrc.d/"; then
  for _ in "${HOME}/.xinitrc.d"/*.sh; do
    if test -f "$_" && test -r "$_"; then
      . "$_"
    fi
  done
fi

## pass control to a window manager
exec awesome
