# dircolors.sh : dircolors config
# see dircolors(1)

if command -v dircolors > /dev/null
then
  if test -f "${XDG_CONFIG_HOME:-${HOME}/.config}/dircolors"
  then
    eval "$(dircolors -- "${XDG_CONFIG_HOME:-${HOME}/.config}/dircolors")"
  elif test -f "${HOME}/.dircolors"
  then
    eval "$(dircolors -- "${HOME}/.dircolors")"
  else
    eval "$(dircolors)"
  fi
fi

# vim:ft=sh
