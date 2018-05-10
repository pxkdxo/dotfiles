#!/usr/bin/env bash

#
## Initialize a new Xsession
#


## Clear resource database
xrdb -load /dev/null


## merge in system resources
test -r '/etc/X11/xinit/Xresources' &&
  xrdb -merge '/etc/X11/xinit/Xresources'

## run system scripts
test -d '/etc/X11/xinit/xinitrc.d' &&
  for _ in '/etc/X11/xinit/xinitrc.d'/*.sh; do
    if test -f "$_" && test -r "$_"; then
      -. "$_"
    fi
  done


## merge in user resources
test -r "${HOME}/.Xresources" &&
  xrdb -merge "${HOME}/.Xresources"

## run user scripts
test -d "${HOME}/.xinitrc.d" &&
  for _ in "${HOME}/.xinitrc.d"/*.sh; do
    if test -f "$_" && test -r "$_"; then
      -. "$_"
    fi
  done


## pass control to a window manager
exec awesome
