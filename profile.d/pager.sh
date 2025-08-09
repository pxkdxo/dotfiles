#!/usr/bin/env sh
# pager.sh: configure the PAGER environment variable
# see environ(7) and select-editor(1)

SEP="$(printf ' \t\n:')"
SEP="${SEP%:}"

if command -v update-alternatives > /dev/null; then
  while IFS="${SEP}" read -r REPLY; do
    REPLY="${REPLY#"${REPLY%%[![:blank:]]*}"}"
    REPLY="${REPLY%"${REPLY##*[![:blank:]]}"}"
    if test "${REPLY%%[[:blank:]]*}" = 'Value:'; then
      if test -x "${REPLY##*[[:blank:]]}"; then
        export PAGER="${REPLY##*[[:blank:]]}"
      fi
      break
    fi
  done << EOF
$(update-alternatives --query pager 2> /dev/null)
EOF
  unset REPLY
elif command -v less > /dev/null; then
  export PAGER="less"
elif command -v more > /dev/null; then
  export PAGER="more"
fi
