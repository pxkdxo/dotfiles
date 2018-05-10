#
## ~/.bash_logout
#

## Write the history to disk to trigger duplicate removal
if [[ :${HISTCONTROL}: = *:erasedups:* ]]; then
  history -n 
  history -w
fi


( ## Write hash table data to disk
umask 077                                                  \
  && pushd -n "${XDG_DATA_HOME:-"${HOME:?}/.local/share"}" \
  && mkdir --parents "${DIRSTACK[1]}"                      \
  && popd                                                  \
  && mkdir --parents ./bash/hash                           \
  && hash >| ./bash.hash/"$(date +%F_%T)"
)


## Clear and reset the terminal
tput -S <<\@EOF
clear
reset
@EOF
