## ~/.profile
## Patrick DeYoreo

## Initialize the terminal
tput init

## Set our umask
umask 027

## Append our default paths
for _ in "${HOME}"/bin "${HOME}"/.bin "${HOME}"/.local/bin; do
  case ":${PATH}:" in
    *":$_:"* )
      ;;
    * ) PATH="${PATH:+"${PATH}:"}$_"
  esac
done
export PATH

## Set a value for TMPDIR if unset or null
export TMPDIR="${TMPDIR:-"${XDG_RUNTIME_DIR:-/tmp}"}"

## Load additional profiles from ~/.profile.d
if test -d "${HOME}"/.profile.d; then
  for _ in "${HOME}"/.profile.d/?*; do
    test -f "$_" && . "$_"
  done
fi
