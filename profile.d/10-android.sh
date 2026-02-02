#!/usr/bin/env sh
# android.sh: Android/Termux-specific settings

# Check if this is Termux on Android
if test "$(uname -o 2>/dev/null)" = "Android" \
  || test -n "${TERMUX_VERSION:-}" \
  || command -v termux-info > /dev/null
then
  # Set PREFIX if not already set
  if test -n "${PREFIX:=$(cd -- ~/../usr && pwd -P)}" 2> /dev/null
  then
    # Set Termux-specific environment variables
    export PREFIX="${PREFIX}"
    export TMPDIR="${TMPDIR:-${TMP:=${PREFIX}/tmp}}"
    export TMP="${TMPDIR}"
    export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-${PREFIX}/var/run}"
  else
    unset PREFIX
  fi
fi


# vim:ft=sh
