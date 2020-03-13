# pager.sh: configure the PAGER environment variable
# see environ(7) and select-editor(1)

#command -v nvim > /dev/null && {
#  export PAGER="nvim +'set ft=man' +'set ft=' +'filetype off' +'syntax on' -"
#} || {
while read -r REPLY
do
  REPLY="${REPLY#"${REPLY%%[![:blank:]]*}"}"
  REPLY="${REPLY%"${REPLY##*[![:blank:]]}"}"
  if test "${REPLY%%[[:blank:]]*}" = 'Value:'
  then
    if test -x "${REPLY##*[[:blank:]]}"
    then
      export PAGER="${REPLY##*[[:blank:]]}"
    fi
    break
  fi
done << STOP
$(update-alternatives --query pager)
STOP
unset REPLY
