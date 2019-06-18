## Load xdg-user-dirs environment variables

if test -f "${XDG_CONFIG_HOME:-"${HOME-}/.config"}/user-dirs.dirs"; then
  . "${XDG_CONFIG_HOME:-"${HOME-}/.config"}/user-dirs.dirs"
fi
