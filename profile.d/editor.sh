#!/usr/bin/env sh
# editor.sh: configure the EDITOR environment variable
# see environ(7) and select-editor(1)

if command -v update-alternatives > /dev/null; then
  while IFS=$' \t\n' read -r REPLY; do
    REPLY="${REPLY#"${REPLY%%[![:blank:]]*}"}"
    REPLY="${REPLY%"${REPLY##*[![:blank:]]}"}"
    if test "${REPLY%%[[:blank:]]*}" = 'Value:'; then
      if test -x "${REPLY##*[[:blank:]]}"; then
        export EDITOR="${REPLY##*[[:blank:]]}"
      fi
      break
    fi
  done << EOF
$(update-alternatives --query editor 2> /dev/null)
EOF
  unset REPLY
elif command -v nvim > /dev/null; then
  export EDITOR="nvim"
elif command -v vim > /dev/null; then
  export EDITOR="vim"
fi
