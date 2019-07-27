## xdg_user_dirs.sh : load xdg-user-dirs variable definitions


if test -f "${XDG_CONFIG_HOME:-${HOME-}/.config}/user-dirs.dirs" &&
   test -r "${XDG_CONFIG_HOME:-${HOME-}/.config}/user-dirs.dirs"
then
  . "${XDG_CONFIG_HOME:-${HOME-}/.config}/user-dirs.dirs"
fi


# vim:ft=sh
