## gpg-agent.sh : gpg-agent environment configuration


## Set GPG_TTY to the current tty and add it to the environment
if tty --silent; then
  GPG_TTY="$(tty)"
else
  GPG_TTY=""
fi
export GPG_TTY


## Refresh gpg-agent in case the user switched to an Xsession
gpg-connect-agent updatestartuptty /bye 1>/dev/null 2>&1


## Configure SSH to use gpg-agent instead of ssh-agent
if ! test -S "${SSH_AUTH_SOCK-}"; then
  unset -v SSH_AGENT_PID
  if test "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne "$$"; then
    SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    export SSH_AUTH_SOCK
  fi
fi


# vi:ft=sh
