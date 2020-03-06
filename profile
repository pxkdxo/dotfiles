# ~/.profile: login shell initialization script
# see bash(1), dash(1), sh(1), zsh(1), ...

# Initialize terminal
if test -t 1
then
  if command -v tput 1> /dev/null
  then
    tput init
  fi
  if command -v stty 1> /dev/null
  then
    stty start '^-' stop '^-'
  fi
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
fi << END
$(getent passwd -- "${USER:-$(id -u)}" 2> /dev/null)
END
export HOME

# Import user environment from systemd
while read -r REPLY
do
  case "${REPLY%%=*}" in
    *[!0-9A-Za-z_]*)
      ;;
    ?*)
      if eval test -z '"${'"${REPLY%%=*}"'+_}"'
      then
        eval export "${REPLY}"
      fi
      ;;
  esac
done << STOP
$(systemctl --user show-environment 2>/dev/null)
STOP
unset -v REPLY

# Prepend executable paths
for dir in .local/bin .bin
do
  if test -d "${HOME}/${dir}"
  then
    export PATH="${HOME:+${HOME}/${dir}${PATH:+:}}${PATH}"
  fi
done
unset -v dir

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

# vi:ft=sh
