#!/usr/bin/env sh
#
# xinit initialization script


# Define globals

SYSRESOURCES='/etc/X11/Xresources'
USERRESOURCES="${HOME}/.Xresources"

SYSXINITDIR='/etc/X11/xinit/xinitrc.d'
USERXINITDIR="${HOME}/.xinitrc.d"

WM="${WM:-awesome}"


# Merge in system resources

if test -f "${SYSRESOURCES}"
then
    xrdb -merge "${SYSRESOURCES}"

elif test -d "${SYSRESOURCES}"
then
    for f in "${SYSRESOURCES}"/*
    do
        if test -f "${f}"
        then
            xrdb -merge "${f}"
        fi
    done
fi
unset -v f


# Merge in user resources

if test -f "${USERRESOURCES}"
then
    xrdb -merge -I"${HOME}" "${USERRESOURCES}"

elif test -d "${USERRESOURCES}"
then
    for f in "${USERRESOURCES}"/*
    do
        if test -f "${f}"
        then
            xrdb -merge -I"${HOME}" "${f}"
        fi
    done
fi
unset -v f


# Run system config scripts

if test -d "${SYSXINITDIR}"
then
    for f in "${SYSXINITDIR}"/*
    do
        if test -f "${f}"
        then
            . "${f}"
        fi
    done
fi
unset -v f


# Run user config scripts

if test -d "${USERXINITDIR}"
then
    for f in "${USERXINITDIR}"/*
    do
        if test -f "${f}"
        then
            . "${f}"
        fi
    done
fi
unset -v f


# Pass control to window manager

if command -v "${WM}" > /dev/null
then
  exec "${WM}"
fi
exit 127


# vi:ft=sh
