## ~/.profile : login shell initialization script
## Maintained by Patrick DeYoreo


## Import environment from systemd
eval export "$(command -p systemctl --user show-environment)"


## Initialize terminal
tput init


## Set file creation mode mask
if test "$(( UID ))" -eq 0; then
  umask 002
else
  umask 022
fi


## Prepend my executable paths
for _ in "${HOME}/.bin" "${HOME}/.local/bin"; do
  case ":${PATH}:" in
    *":$_:"*)
      ;;
    *)
      PATH="$_${PATH:+":${PATH}"}"
      ;;
  esac
done
export PATH


## Load additional config
if test -d "${HOME}/.profile.d"; then
  for _ in "${HOME}/.profile.d"/*.sh; do
    if test -f "$_" && test -r "$_"; then
      . "$_"
    fi
  done 1>/dev/null
fi


## Set size of command history
export HISTSIZE=10000


## Termcap should be dead; kill it
unset -v TERMCAP


## Man is better at figuring this out than we are
unset -v MANPATH



## End of Script
