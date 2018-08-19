## less_termcap.sh : escape sequences interpreted by 'less'
## maintained by Patrick DeYoreo


## Characters that are allowed to end a video escape sequence
export LESSANSIENDCHARS='m'

## Characters that are allowed within a video escape sequence
export LESSANSIMIDCHARS=';:!?'"'"'"()[*#%+ 0123456789B'


## Skip the rest if 'tput' is not available (requires ncurses) 
if command -pv tput 1>/dev/null; then

  ## Enter blink mode
  if LESS_TERMCAP_mb="$(command -p tput bold)"; then
    export LESS_TERMCAP_mb
  fi
  
  ## Enter bold mode
  if LESS_TERMCAP_md="$(command -p tput blink)"; then
    export LESS_TERMCAP_md
  fi
  
  ## End all video attributes
  if LESS_TERMCAP_me="$(command -p tput sgr0)"; then
    export LESS_TERMCAP_me
  fi
  
  ## Enter standout mode (reverse-video + bold)
  if LESS_TERMCAP_so="$(command -p tput smso)"; then
    export LESS_TERMCAP_so
  fi
  
  ## End standout mode
  if LESS_TERMCAP_se="$(command -p tput rmso)"; then
    export LESS_TERMCAP_se
  fi
  
  ## Enter underline mode
  if LESS_TERMCAP_us="$(command -p tput smul)"; then
    export LESS_TERMCAP_us
  fi
  
  ## End underline mode
  if LESS_TERMCAP_ue="$(command -p tput rmul)"; then
    export LESS_TERMCAP_ue
  fi
  
  ## Enter reverse-video mode
  if LESS_TERMCAP_mr="$(command -p tput rev)"; then
    export LESS_TERMCAP_mr
  fi
  
  ## Enter dim mode
  if LESS_TERMCAP_mh="$(command -p tput dim)"; then
    export LESS_TERMCAP_mh
  fi
  
  ## Enter subscript mode
  if LESS_TERMCAP_ZN="$(command -p tput ssubm)"; then
    export LESS_TERMCAP_ZN
  fi
  
  ## End subscript mode
  if LESS_TERMCAP_ZV="$(command -p tput rsubm)"; then
    export LESS_TERMCAP_ZV
  fi
  
  ## Enter superscript mode
  if LESS_TERMCAP_ZO="$(command -p tput ssupm)"; then
    export LESS_TERMCAP_ZO
  fi
  
  ## End superscript mode
  if LESS_TERMCAP_ZW="$(command -p tput rsupm)"; then
    export LESS_TERMCAP_ZW
  fi

fi 2>/dev/null
