## ranger.sh : setup ranger to skip the default rc if a user-specific rc exists

if test -d "${XDG_CONFIG_HOME:-${HOME-}/.config}/ranger"; then
  RANGER_LOAD_DEFAULT_RC='FALSE'
else
  RANGER_LOAD_DEFAULT_RC='TRUE'
fi
export RANGER_LOAD_DEFAULT_RC


# vim:ft=sh
