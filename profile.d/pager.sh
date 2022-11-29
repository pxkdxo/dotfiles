#!/usr/bin/env sh
# pager.sh: configure the PAGER environment variable
# see environ(7) and select-editor(1)

if command -v update-alternatives > /dev/null; then
  while IFS=$' \t\n' read -r REPLY; do
    REPLY="${REPLY#"${REPLY%%[![:blank:]]*}"}"
    REPLY="${REPLY%"${REPLY##*[![:blank:]]}"}"
    if test "${REPLY%%[[:blank:]]*}" = 'Value:'; then
      if test -x "${REPLY##*[[:blank:]]}"; then
        export PAGER="${REPLY##*[[:blank:]]}"
      fi
      break
    fi
  done
  unset REPLY
fi << EOF
$(update-alternatives --query pager 2> /dev/null)
EOF
