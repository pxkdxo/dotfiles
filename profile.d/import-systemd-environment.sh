# import-systemd-environment.sh: import systemd user environment

while read -r REPLY
do
  case "${REPLY%%=*}" in
    [![:alpha:]_]*|?*[![:alnum:]_]*)
      ;;
    ?*)
      if eval test -z '"${'"${REPLY%%=*}"'+_}"'
      then eval export "${REPLY}"
      fi
      ;;
  esac
done << STOP
$(systemctl --user show-environment 2> /dev/null)
STOP

# vim:ft=sh
