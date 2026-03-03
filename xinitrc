#!/usr/bin/env sh
# ~/.xinitrc: xinit initialization script

# Exit upon errors and unset variable expansions
set -eu

# Run profile setup
for __xprofile in "${XDG_CONFIG_HOME:-${HOME}/.config}/xprofile" "${HOME}/.xprofile"; do
  if test -f "${__xprofile}" && test -r "${__xprofile}"; then
    . "${__xprofile}"
    break
  fi
done
unset __xprofile

# Identify session
case "${1-}" in
  awesome)
    session=awesome
    ;;
  cinnamon)
    session=cinnamon-session
    ;;
  gnome)
    session=gnome-session
    ;;
  kde)
    session=startplasma-x11
    ;;
  lxde)
    session=startlxde
    ;;
  lxqt)
    session=lxqt-session
    ;;
  mate)
    session=mate-session
    ;;
  xfce)
    session=xfce4-session
    ;;
  *)
    session=""
    ;;
esac

# Become the session or exit with failure
command -v "${session}" > /dev/null && exec dbus-launch --sh-syntax --exit-with-session "${session}" || exit 127

# vi:ft=sh
