# ~/.zshenv: startup script for zsh login shells
# NOTE: copied directly from bash_profile

# Load config for login shells
if [[ -f ~/.profile ]]
then source ~/.profile
fi

# Load config for interactive shells
if [[ $- == *i* ]]
then
  if [[ -n ${ZDOTDIR} ]]
  then
    if [[ -f ${ZDOTDIR}/zshrc ]]
    then source "${ZDOTDIR}/zshrc"
    fi
  else
    if [[ -f ~/.zshrc ]]
    then source ~/.zshrc
    fi
  fi
fi

# Upon login in at tty1, start an Xsession
if [[ -z ${DISPLAY-} ]] && ((XDG_VTNR == 1 )) && command -v startx > /dev/null
then exec startx
fi

# vi:ft=sh
