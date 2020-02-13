# xdg_user_dirs.sh : load xdg-user-dirs variable definitions

[ -f "${XDG_CONFIG_HOME:-${HOME-}/.config}/user-dirs.dirs" ] &&
  .  "${XDG_CONFIG_HOME:-${HOME-}/.config}/user-dirs.dirs"

# vim:ft=sh
