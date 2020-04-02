# dircolors.sh : dircolors config
# see dircolors(1)

if command -v dircolors > /dev/null
then
  { test -f "${XDG_CONFIG_HOME:-${HOME}/.config}/dircolors" &&
    eval "$(dircolors -- "${XDG_CONFIG_HOME:-${HOME}/.config}/dircolors")"
  } ||
  { test -f "${HOME}/.dircolors" &&
    eval "$(dircolors -- "${HOME}/.dircolors")"
  } ||
  { eval "$(dircolors)"
  }
fi 2> /dev/null

# vim:ft=sh
