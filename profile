# ~/.profile: login shell initialization script
# see sh(1), bash(1), dash(1), ...

# Initialize terminal
if test -t 1 && command -v tput 1> /dev/null
then
  tput init
fi

# Set file creation mode mask
if test "${UID:-$(id -u)}" -eq 0
then
  umask 0002
else
  umask 0022
fi

# If HOME is unset or NULL, try to set it
if test -z "${HOME-}"
then
  IFS=':' read -r _ _ _ _ _ HOME _
fi << STOP
$(getent passwd -- "${UID:-$(id -u)}" 2> /dev/null)
STOP

# Prepend executable paths
if test -d "${HOME}/.local/bin"
then
  export PATH="${HOME}/.local/bin${PATH:+:${PATH}}"
fi
if test -d "${HOME}/.bin"
then
  export PATH="${HOME}/.bin${PATH:+:${PATH}}"
fi

# Load additional profile config
if test -d "${HOME}/.profile.d"
then
  for file in "${HOME}/.profile.d"/*.sh
  do
    if test -f "${file}" && test -r "${file}"
    then
      . "${file}"
    fi
  done
fi
unset -v file

## Termcap should be dead; kill it
unset -v TERMCAP

## Man is much better at figuring this out than we are
unset -v MANPATH

# vi:ft=sh
