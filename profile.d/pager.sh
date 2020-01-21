# pager.sh: configure the PAGER environment variable
# see environ(7) and select-editor(1)

while IFS=$': \t' read k v
do
  if test "${k}" = 'Value'
  then
    if test -x "${v}"
    then export PAGER="${v}"
    fi
    break;
  fi
done << STOP
$(update-alternatives --query pager)
STOP
unset k v
