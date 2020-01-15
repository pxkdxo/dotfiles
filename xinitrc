#!/usr/bin/env sh
#
# xinit initialization script


# Initialize global variables.

SYSRESOURCES='/etc/X11/Xresources'
USERRESOURCES="${HOME}/.Xresources"

SYSXINITRCDIR='/etc/X11/xinit/xinitrc.d'
USERXINITRCDIR="${HOME}/.xinitrc.d"

WM="${WM:-awesome}"


# Merge in system resources.

if test -f "${SYSRESOURCES}"
then
    xrdb -merge "${SYSRESOURCES}"

elif test -d "${SYSRESOURCES}"
then
    for _ in "${SYSRESOURCES}"/*
    do
        if test -f "$_" && test -r "$_"
        then
            xrdb -merge "$_"
        fi
    done
fi


# Merge in user resources.

if test -f "${USERRESOURCES}"
then
    xrdb -merge -I"${HOME}" "${USERRESOURCES}"

elif test -d "${USERRESOURCES}"
then
    for _ in "${USERRESOURCES}"/*
    do
        if test -f "$_" && test -r "$_"
        then
            xrdb -merge -I"${HOME}" "$_"
        fi
    done
fi


# Run system config scripts.

if test -d "${SYSXINITRCDIR}"
then
    for _ in "${SYSXINITRCDIR}"/*
    do
        if test -f "$_" && test -r "$_"
        then
            . "$_"
        fi
    done
fi


# Run user config scripts.

if test -d "${USERXINITRCDIR}"
then
    for _ in "${USERXINITRCDIR}"/*
    do
        if test -f "$_" && test -r "$_"
        then
            . "$_"
        fi
    done
fi


# Pass control to window manager.

if command -v "${WM}" 1> /dev/null
then
  exec "${WM}"
fi
exit 127


# vi:ft=sh
