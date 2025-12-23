#!/usr/bin/env sh
# pager.sh: configure the PAGER environment variable
# see environ(7) and select-editor(1)

# Skip if PAGER is already set
if test -n "${PAGER:-}"; then
  return 0
fi

# Try update-alternatives first (Debian/Ubuntu)
if command -v update-alternatives > /dev/null; then
  pager_path="$(update-alternatives --query pager 2>/dev/null | \
    grep -E '^Value:' | \
    sed 's/^Value:[[:space:]]*//' | \
    head -1)"
  
  if test -n "${pager_path}" && test -x "${pager_path}"; then
    export PAGER="${pager_path}"
    unset pager_path
    return 0
  fi
  unset pager_path
fi

# Fallback to common pagers in order of preference
for pager in pager less more; do
  if command -v "${pager}" > /dev/null; then
    export PAGER="${pager}"
    return 0
  fi
done

# vim:ft=sh
