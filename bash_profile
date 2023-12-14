# ~/.bash_profile: startup script for bash login shells

# Load config for login shells
if [[ -f ~/.profile && -r ~/.profile ]]
then
  source ~/.profile
fi

# Load config for interactive shells
if [[ -f ~/.bashrc && -r ~/.bashrc ]]
then
  source ~/.bashrc
fi

# Upon login in at tty1, start an Xsession
if [[ -z ${DISPLAY-} ]] && (( XDG_VTNR == 1 )) && command -v startx > /dev/null
then
  exec startx
fi

# vi:ft=sh

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/pat/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
