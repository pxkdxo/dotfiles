# gpg-agent.sh : gpg-agent config
# see gpg-agent(1)


# Set GPG_TTY to the tty on stdin
GPG_TTY="$(tty)" || GPG_TTY="" && export GPG_TTY

# Refresh gpg-agent
gpg-connect-agent updatestartuptty /bye 1>/dev/null 2>&1

# Configure SSH to use gpg-agent
if ! test -S "${SSH_AUTH_SOCK-}"
then
    unset -v SSH_AGENT_PID

    if test "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne "$$"
    then
        SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)" &&
            export SSH_AUTH_SOCK
    fi
fi


# vi:ft=sh
