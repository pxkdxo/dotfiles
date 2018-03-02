## ~/.profile
## Patrick DeYoreo

## Set a umask
umask 027

## Append some default paths to PATH
for _ in "${HOME}" "${HOME}/bin" "${HOME}/.bin" "${HOME}/.local/bin"; do
  case ":${PATH}:" in
    *":$_:"* )
      ;;
    * ) PATH="${PATH:+${PATH}:}$_"
  esac
done

## Ensure changes to PATH are reflected in the environment
export PATH

## Set a default value for TMPDIR if it is unset or null
TMPDIR="${TMPDIR:-${XDG_RUNTIME_DIR:-/tmp}}"

## Export TMPDIR to the environment
export TMPDIR

## Source additional profile configuration
if test -d "${HOME}/.profile.d"; then
  for _ in "${HOME}/.profile.d"/?*; do
    test -f "$_" && . "$_"
  done
fi

## -- END --
