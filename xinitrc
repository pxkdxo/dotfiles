#!/usr/bin/env sh
#
# ~/.xinitrc: xinit initialization script

# Define globals
DEFAULT_SESSION="kde"
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
if test -f "${USERRESOURCES}"; then
  xrdb -merge -I"${HOME}" "${USERRESOURCES}"

elif test -d "${USERRESOURCES}"; then
  for name in "${USERRESOURCES}"/*; do
    if test -f "${name}"; then
      xrdb -merge -I"${HOME}" "${name}"
    fi
  done
  unset name
fi

if test -f "${SYSMODMAP}"; then
  xmodmap "${SYSMODMAP}"
fi

# Run system config scripts
if test -d "${SYSSESSIONDIR}"; then
  for name in "${SYSSESSIONDIR}"/?*.sh; do
    if test -f "${name}"; then
      . "${name}"
    fi
  done
  unset name
fi

if test -f "${USERMODMAP}"; then
  xmodmap "${USERMODMAP}"
fi

# Run user config scripts
if test -d "${USERSESSIONDIR}" && test -r "${USERSESSIONDIR}"; then
  for name in "${USERSESSIONDIR}"/?*.sh; do
    if test -f "${name}" && test -r "${name}"; then
      . "${name}"
    fi
  done
  unset name
fi

print_dbus_launch() {
  printf -- '%s %s %s %s\n' dbus-launch --sh-syntax --exit-with-session "$1"
}

get_session(){
  local session="${DEFAULT_SESSION}"
  case "$1" in
    awesome) session=awesome ;;
    bspwm) session=bspwm-session ;;
    budgie) session=budgie-desktop ;;
    cinnamon) session=cinnamon-session ;;
    deepin) session=startdde ;;
    enlightenment) session=enlightenment_start ;;
    fluxbox) session=startfluxbox ;;
    gnome) session=gnome-session ;;
    i3|i3wm) session=i3 ;;
    jwm) session=jwm ;;
    kde) session=startplasma-x11 ;;
    lxde) session=startlxde ;;
    lxqt) session=lxqt-session ;;
    mate) session=mate-session ;;
    xfce) session=xfce4-session ;;
    openbox) session=openbox-session ;;
  esac
  print_dbus_launch "${session}"
}

exec $(get_session "$1")

exit 127

# vi:ft=sh
