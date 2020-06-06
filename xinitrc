#!/usr/bin/env sh
#
# xinit initialization script


# Define globals

SYSRESOURCES='/etc/X11/Xresources'
USERRESOURCES="${HOME}/.Xresources"

SYSSESSIONDIR='/etc/X11/xinit/xinitrc.d'
USERSESSIONDIR="${HOME}/.xinitrc.d"

WM="${WM:-awesome}"


# Merge in system resources

if test -f "${SYSRESOURCES}" && test -r "${SYSRESOURCES}"
then
    xrdb -merge "${SYSRESOURCES}"

elif test -d "${SYSRESOURCES}" && test -r "${SYSRESOURCES}"
then
    for file in "${SYSRESOURCES}"/*
    do
        if test -f "${file}" && test -r "${file}"
        then
            xrdb -merge "${file}"
        fi
    done
    unset -v file
fi


# Merge in user resources

if test -f "${USERRESOURCES}" && test -r "${USERRESOURCES}"
then
    xrdb -merge -I"${HOME}" "${USERRESOURCES}"

elif test -d "${USERRESOURCES}" && test -r "${USERRESOURCES}"
then
    for file in "${USERRESOURCES}"/*
    do
        if test -f "${file}" && test -r "${file}"
        then
            xrdb -merge -I"${HOME}" "${file}"
        fi
    done
    unset -v file
fi


# Run system config scripts

if test -d "${SYSSESSIONDIR}" && test -r "${SYSSESSIONDIR}"
then
    for file in "${SYSSESSIONDIR}"/*
    do
        if test -f "${file}" && test -r "${file}"
        then
            . "${file}"
        fi
    done
    unset -v file
fi


# Run user config scripts

if test -d "${USERSESSIONDIR}" && test -r "${USERSESSIONDIR}"
then
    for file in "${USERSESSIONDIR}"/*
    do
        if test -f "${file}" && test -r "${file}"
        then
            . "${file}"
        fi
    done
    unset -v file
fi


# Exec a window manager

if command -v "${WM}" > /dev/null
then
  exec "${WM}"
fi
exit 127


# vi:ft=sh
