## ~/.profile : login shell init file

## Initialize terminal
tput init


## Set file creation mode mask
umask 027


## Prepend my executable paths
for _ in "${HOME}"/bin "${HOME}"/.bin "${HOME}"/.local/bin; do
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
if test -d "${HOME}"/.profile.d; then
  for _ in "${HOME}"/.profile.d/*; do
    test -f "$_" && . "$_"
  done
fi
