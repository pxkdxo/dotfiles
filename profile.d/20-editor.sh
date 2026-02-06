#!/usr/bin/env sh
# editor.sh: configure the EDITOR environment variable
# see environ(7) and select-editor(1)

# Try update-alternatives first (Debian/Ubuntu)
if command -v update-alternatives > /dev/null && EDITOR="$(
    command -v -- "$(
      update-alternatives --query editor | sed -E -n '
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
  export EDITOR
else
  for EDITOR in nvim vim vi; do
    if EDITOR="$(command -v -- "${EDITOR}")"; then
      export EDITOR
      break
    fi
  done
fi
if test -z "${EDITOR}"; then
  unset EDITOR
fi


# vim:ft=sh
