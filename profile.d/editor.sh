#!/usr/bin/env sh
# editor.sh: configure the EDITOR environment variable
# see environ(7) and select-editor(1)

# Skip if EDITOR is already set
if test -n "${EDITOR:-}"; then
  return 0
fi

# Try update-alternatives first (Debian/Ubuntu)
if command -v update-alternatives > /dev/null; then
  editor_path="$(update-alternatives --query editor 2>/dev/null | \
    grep -E '^Value:' | \
    sed 's/^Value:[[:space:]]*//' | \
    head -1)"
  
  if test -n "${editor_path}" && test -x "${editor_path}"; then
    export EDITOR="${editor_path}"
    unset editor_path
    return 0
  fi
  unset editor_path
fi

# Fallback to common editors in order of preference
for editor in editor nvim vim vi nano; do
  if command -v "${editor}" > /dev/null; then
    export EDITOR="${editor}"
    return 0
  fi
done

# vim:ft=sh
