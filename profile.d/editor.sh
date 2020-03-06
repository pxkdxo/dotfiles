# editor.sh: configure the EDITOR environment variable
# see environ(7) and select-editor(1)

while read REPLY
do
  REPLY="${REPLY#"${REPLY%%[![:blank:]]*}"}"
  REPLY="${REPLY%"${REPLY##*[![:blank:]]}"}"
  if test "${REPLY%%[[:blank:]]*}" = 'Value:'
  then
    if test -x "${REPLY##*[[:blank:]]}"
    then
      export EDITOR="${REPLY##*[[:blank:]]}"
    fi
    break
  fi
done << STOP
$(update-alternatives --query editor)
STOP
unset REPLY
