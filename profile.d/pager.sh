#!/usr/bin/env sh
# pager.sh: configure the PAGER environment variable
# see environ(7) and select-pager(1)

# Try update-alternatives first (Debian/Ubuntu)
if command -v update-alternatives > /dev/null && PAGER="$(
    command -v -- "$(
      update-alternatives --query pager | sed -E -n '
      # Find the line starting with "Value:" and extract the value it contains
      s/^[[:blank:]]*Value:[[:blank:]]*(.*[^[:blank:]])[[:blank:]]*$/\1/
      t z # Skip to z if matched
      d # Otherwise delete the line and start again
      : z # Print the line and quit
      p
      q
      '
    )"
  )"
then
  export PAGER
else
  for PAGER in bat less more; do
    if PAGER="$(command -v -- "${PAGER}")"; then
      export PAGER
      break
    fi
  done
fi
if test -z "${PAGER}"; then
  unset PAGER
fi


# vim:ft=sh
