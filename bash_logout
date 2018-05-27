#
## ~/.bash_logout
#


## Write the history to disk to trigger duplicate removal
if [[ :${HISTCONTROL}: = *:erasedups:* ]]; then
  history -n 
  history -w
fi


## Write hash table data to disk
(
umask 077                                                             \
  && pushd -n "${XDG_DATA_HOME:-"${HOME:?}/.local/share"}/bash/hash"  \
  && mkdir --parents ~+1                                              \
  && hash >| ~+1/"$(date +%Y-%d-%m_%H.%M.%S)"
) 1>/dev/null 2>&1


## Clear and reset the terminal
tput -S << /end
clear
reset
/end
