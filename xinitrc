#!/bin/env bash

## merge in system resources
[[ -r '/etc/X11/xinit/Xresources' ]] &&
  xrdb -merge '/etc/X11/xinit/Xresources'

## run system scripts
[[ -d '/etc/X11/xinit/xinitrc.d' ]] &&
  for _ in '/etc/X11/xinit/xinitrc.d'/*.sh; do
    [[ -r "$_" ]] && . "$_"
  done

## merge in user resources
[[ -r "${HOME}/.Xresources" ]] &&
  xrdb -merge "${HOME}/.Xresources"

## run user scripts
[[ -d "${HOME}/.xinitrc.d" ]] &&
  for _ in "${HOME}/.xinitrc.d"/*.sh; do
    [[ -r "$_" ]] && . "$_"
  done

## pass control to window manager
exec awesome
