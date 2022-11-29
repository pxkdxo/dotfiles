#!/usr/bin/env sh
#
# ~/.xinitrc: xinit initialization script


# Define globals
SYSRESOURCES='/etc/X11/Xresources'
SYSMODMAP='/etc/X11/xinit/.Xmodmap'
SYSSESSIONDIR='/etc/X11/xinit/xinitrc.d'
USERRESOURCES="${HOME}/.Xresources"
USERMODMAP="${HOME}/.Xmodmap"
USERSESSIONDIR="${HOME}/.xinitrc.d"

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
    for name in "${SYSSESSIONDIR}"/?*.sh; do
        if test -f "${name}" && test -r "${name}"; then
            . "${name}"
        fi
    done
    unset -v name
fi

# Run user config scripts
if test -d "${USERSESSIONDIR}" && test -r "${USERSESSIONDIR}"; then
    for name in "${USERSESSIONDIR}"/?*.sh; do
        if test -f "${name}" && test -r "${name}"; then
            . "${name}"
        fi
    done
    unset -v name
fi

get_session(){
    local dbus_args=(--sh-syntax --exit-with-session)
    case $1 in
        awesome) dbus_args+=(awesome) ;;
        bspwm) dbus_args+=(bspwm-session) ;;
        budgie) dbus_args+=(budgie-desktop) ;;
        cinnamon) dbus_args+=(cinnamon-session) ;;
        deepin) dbus_args+=(startdde) ;;
        enlightenment) dbus_args+=(enlightenment_start) ;;
        fluxbox) dbus_args+=(startfluxbox) ;;
        gnome) dbus_args+=(gnome-session) ;;
        i3|i3wm) dbus_args+=(i3 --shmlog-size 0) ;;
        jwm) dbus_args+=(jwm) ;;
        kde) dbus_args+=(startplasma-x11) ;;
        lxde) dbus_args+=(startlxde) ;;
        lxqt) dbus_args+=(lxqt-session) ;;
        mate) dbus_args+=(mate-session) ;;
        xfce) dbus_args+=(xfce4-session) ;;
        openbox) dbus_args+=(openbox-session) ;;
        *) dbus_args+=($DEFAULT_SESSION) ;;
    esac

    echo "dbus-launch ${dbus_args[*]}"
}

exec $(get_session "$1")

exit 127

# vi:ft=sh
