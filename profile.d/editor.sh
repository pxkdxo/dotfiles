#!/usr/bin/env sh
# editor.sh: configure the EDITOR environment variable
# see environ(7) and select-editor(1)

# Try update-alternatives first (Debian/Ubuntu)
if command -v update-alternatives > /dev/null; then
  EDITOR="$(command -v -- "$(update-alternatives --query editor | sed -n '
    s/^[[:blank:]]*[Vv]alue:[[:blank:]]*\(.*[^[:blank:]]\)[[:blank:]]*$/\1/
    tn
    d
    :n
    /[^[:blank:]]/bq
    d
    :q
    p
    q'
  )" 2> /dev/null)"
fi
if test -n "${EDITOR}" && test -x "${EDITOR}"; then
  export EDITOR
else
  # Fallback to common editors in order of preference
  for EDITOR in nvim vim vi editor; do
    if EDITOR="$(command -v -- "${EDITOR}")"; then
      export EDITOR
      break
    fi
  done
fi


# vim:ft=sh
