#!/usr/bin/env sh
# ~/profile.d/android.sh: Android-specific settings

if {
  test -n "${TERMUX_VERSION+X}" || command -v termux-info > /dev/null
} &&
  test "$(uname -o 2> /dev/null)" = "Android"
then
  if test -z "${PREFIX+X}"
  then
    if PREFIX="$(cd -- ~/../usr 2> /dev/null && pwd -P 2> /dev/null && echo 'X')"
    then
      PREFIX="${PREFIX%?X}"
    else
      unset PREFIX
    fi
  fi
  if test -n "${PREFIX+X}"
  then
    export TMPDIR="${TMPDIR:-${TMP:-${PREFIX}/tmp}}"
    export TMP="${TMPDIR}"
    export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-${PREFIX}/var/run}"
  fi
fi
