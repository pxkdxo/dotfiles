#!/usr/bin/env sh
# editor.sh: configure the EDITOR environment variable
# see environ(7) and select-editor(1)

if command -v editor; then
  export EDITOR="editor"
elif command -v update-alternatives > /dev/null; then
  unset OLD_IFS
  if test -n "${IFS+X}"; then
    OLD_IFS="${IFS}"
  fi
  unset IFS
  while read -r REPLY; do
    REPLY="${REPLY#"${REPLY%%[![:blank:]]*}"}"
    REPLY="${REPLY%"${REPLY##*[![:blank:]]}"}"
    if test "${REPLY%%[[:blank:]]*}" = 'Value:'; then
      if test -x "${REPLY#"${REPLY%%/*}"}"; then
        export EDITOR="${REPLY##*[[:blank:]]}"
        break
      fi
    fi
  done << EOF
$(update-alternatives --query editor 2> /dev/null)
EOF
  unset REPLY
  if test -n "${OLD_IFS+X}"; then
    export IFS="${OLD_IFS}"
  fi
elif command -v nvim > /dev/null; then
  export EDITOR="nvim"
elif command -v vim > /dev/null; then
  export EDITOR="vim"
elif command -v vi > /dev/null; then
  export EDITOR="vi"
fi
