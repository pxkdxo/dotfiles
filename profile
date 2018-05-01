## ~/.profile : login shell init file

## Initialize terminal
command -p tput init


## Set file creation mode mask
umask 027


## Prepend my executable paths
for _ in "${HOME}"/bin "${HOME}"/.local/bin; do
  if test -d "$_"; then
    case ":${PATH}:" in
      *":$_:"*)
        ;;
      *)
        PATH="$_${PATH:+":${PATH}"}"
        ;;
    esac
  fi
done
export PATH


## Load additional profile config
if test -d "${HOME}"/.profile.d && test -r "${HOME}"/.profile.d; then
  for _ in "${HOME}"/.profile.d/*; do
    test -f "$_" && test -r "$_" && . "$_"
  done
fi
