#!/usr/bin/env sh
# android.sh: Android/Termux-specific settings

# Check if we're running on Android/Termux
if test "$(uname -o 2>/dev/null)" != "Android"; then
  return 0
fi

# Check for Termux environment
if test -z "${TERMUX_VERSION:-}" && ! command -v termux-info > /dev/null; then
  return 0
fi

# Set PREFIX if not already set
if test -z "${PREFIX:-}"; then
  prefix_path="$(cd -- ~/../usr 2>/dev/null && pwd -P 2>/dev/null)"
  if test -n "${prefix_path}" && test -d "${prefix_path}"; then
    export PREFIX="${prefix_path}"
  else
    unset prefix_path
    return 0
  fi
  unset prefix_path
fi

# Set Termux-specific environment variables
if test -n "${PREFIX:-}"; then
  export TMPDIR="${TMPDIR:-${TMP:-${PREFIX}/tmp}}"
  export TMP="${TMPDIR}"
  export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-${PREFIX}/var/run}"
fi

# vim:ft=sh
