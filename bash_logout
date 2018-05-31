#
## ~/.bash_logout
#

## Write hash table data to disk
{ ( mkdir --parents -- "${XDG_DATA_HOME:-${HOME:?}/.local/share}/bash/hash" \
    && hash >| \
    "${XDG_DATA_HOME:-${HOME}/.local/share}/bash/hash/$(date +%F_%H.%M.%S)"
  )
  
  ## Write the history to disk to trigger duplicate removal
  case ":${BASHOPTS}:" in
    *:histappend:*)
      case ":${HISTCONTROL}:" in
        *:erasedups:*)
          history -n
          history -w
          history -c
      esac
  esac 
} 1>/dev/null 2>&1


## Clear and reset the terminal
tput clear
tput reset
