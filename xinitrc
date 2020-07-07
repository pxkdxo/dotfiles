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

if test -f "${SYSRESOURCES}" && test -r "${SYSRESOURCES}"; then
    xrdb -merge "${SYSRESOURCES}"

elif test -d "${SYSRESOURCES}" && test -r "${SYSRESOURCES}"; then
    for name in "${SYSRESOURCES}"/*; do
        if test -f "${name}" && test -r "${name}"; then
            xrdb -merge "${name}"
        fi
    done
    unset -v name
fi


# Merge in user resources

if test -f "${USERRESOURCES}" && test -r "${USERRESOURCES}"; then
    xrdb -merge -I"${HOME}" "${USERRESOURCES}"

elif test -d "${USERRESOURCES}" && test -r "${USERRESOURCES}"; then
    for name in "${USERRESOURCES}"/*; do
        if test -f "${name}" && test -r "${name}"; then
            xrdb -merge -I"${HOME}" "${name}"
        fi
    done
    unset -v name
fi


# Run system config scripts

if test -d "${SYSSESSIONDIR}" && test -r "${SYSSESSIONDIR}"; then
    for name in "${SYSSESSIONDIR}"/*; do
        if test -f "${name}" && test -r "${name}"; then
            . "${name}"
        fi
    done
    unset -v name
fi


# Run user config scripts

if test -d "${USERSESSIONDIR}" && test -r "${USERSESSIONDIR}"; then
    for name in "${USERSESSIONDIR}"/*; do
        if test -f "${name}" && test -r "${name}"; then
            . "${name}"
        fi
    done
    unset -v name
fi


# Exec a window manager

if command -v "${WM}" > /dev/null; then
  exec "${WM}"
fi
exit 127


# vi:ft=sh
