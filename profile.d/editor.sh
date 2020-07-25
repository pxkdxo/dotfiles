# editor.sh: configure the EDITOR environment variable
# see environ(7) and select-editor(1)

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
