## ~/.bash_profile : startup file for bash login-shells


## Load profile config
if [[ -f ~/.profile && -r ~/.profile ]]; then
  source ~/.profile
fi


## source config for interactive shells
if [[ -f ~/.bashrc && -r ~/.bashrc ]]; then
  source ~/.bashrc
fi


## If logging in at tty1, switch to an Xsession
if [[ -z ${DISPLAY-} && ${XDG_VTNR-} -eq 1 ]] && command -v startx 1>/dev/null
then
  exec startx
fi


## For other logins, switch to a tmux session
#if [[ -z ${TMUX} ]] && command -v tmux >/dev/null; then
#  tmux list-sessions >/dev/null &&
#    exec tmux attach ||
#    exec tmux new-session
#fi


# vi:ft=sh
