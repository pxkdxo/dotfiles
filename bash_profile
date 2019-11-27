# ~/.bash_profile: startup script for bash login shells

# Load config for login shells.
if [[ -f ~/.profile && -r ~/.profile ]]
then
    source ~/.profile
fi

# Load config for interactive shells.
if [[ -f ~/.bashrc && -r ~/.bashrc && $- == *i* ]]
then
    source ~/.bashrc
fi

# Upon login in at tty1, start an Xsession.
if [[ -z ${DISPLAY-} && ${XDG_VTNR-0} -eq 1 ]] && command -v startx 1>/dev/null
then
    exec startx
fi


# vi:ft=sh
