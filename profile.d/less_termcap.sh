## less_termcap.sh : escape sequences interpreted by 'less'
## maintained by Patrick DeYoreo


## Characters that are allowed to end a video escape sequence
LESSANSIENDCHARS='m'
export LESSANSIENDCHARS

## Characters that are allowed within a video escape sequence
LESSANSIMIDCHARS='0123456789B:;[?!"\''#%()*+ '
export LESSANSIMIDCHARS


### Skip the rest if 'tput' is not available (requires ncurses) 
#if command -v tput 1> /dev/null; then
#
#  ## Enter blink mode
#  if LESS_TERMCAP_mb="$(tput bold)"; then
#    export LESS_TERMCAP_mb
#  fi
#  
#  ## Enter bold mode
#  if LESS_TERMCAP_md="$(tput blink)"; then
#    export LESS_TERMCAP_md
#  fi
#  
#  ## End all video attributes
#  if LESS_TERMCAP_me="$(tput sgr0)"; then
#    export LESS_TERMCAP_me
#  fi
#  
#  ## Enter standout mode
#  if LESS_TERMCAP_so="$(tput smso)"; then
#    export LESS_TERMCAP_so
#  fi
#  
#  ## End standout mode
#  if LESS_TERMCAP_se="$(tput rmso)"; then
#    export LESS_TERMCAP_se
#  fi
#  
#  ## Enter underline mode
#  if LESS_TERMCAP_us="$(tput smul)"; then
#    export LESS_TERMCAP_us
#  fi
#  
#  ## End underline mode
#  if LESS_TERMCAP_ue="$(tput rmul)"; then
#    export LESS_TERMCAP_ue
#  fi
#  
#  ## Enter reverse-video mode
#  if LESS_TERMCAP_mr="$(tput rev)"; then
#    export LESS_TERMCAP_mr
#  fi
#  
#  ## Enter dim mode
#  if LESS_TERMCAP_mh="$(tput dim)"; then
#    export LESS_TERMCAP_mh
#  fi
#  
#  ## Enter subscript mode
#  if LESS_TERMCAP_ZN="$(tput ssubm)"; then
#    export LESS_TERMCAP_ZN
#  fi
#  
#  ## End subscript mode
#  if LESS_TERMCAP_ZV="$(tput rsubm)"; then
#    export LESS_TERMCAP_ZV
#  fi
#  
#  ## Enter superscript mode
#  if LESS_TERMCAP_ZO="$(tput ssupm)"; then
#    export LESS_TERMCAP_ZO
#  fi
#  
#  ## End superscript mode
#  if LESS_TERMCAP_ZW="$(tput rsupm)"; then
#    export LESS_TERMCAP_ZW
#  fi
#
#fi &>/dev/null
