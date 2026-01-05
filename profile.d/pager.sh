#!/usr/bin/env sh
# pager.sh: configure the PAGER environment variable
# see environ(7) and select-pager(1)

# Try update-alternatives first (Debian/Ubuntu)
if command -v update-alternatives > /dev/null; then
  PAGER="$(command -v -- "$(update-alternatives --query pager | sed -n '
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
if test -n "${PAGER}" && test -x "${PAGER}"; then
  export PAGER
else
  # Fallback to common pagers in order of preference
  for PAGER in bat less more pager; do
    if PAGER="$(command -v -- "${PAGER}")"; then
      export PAGER
      break
    fi
  done
fi


# vim:ft=sh
