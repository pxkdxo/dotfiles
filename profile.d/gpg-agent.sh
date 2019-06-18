#!/usr/bin/env sh


## Set GPG_TTY to the current tty
if tty --silent; then
  GPG_TTY="$(tty)"
else
  GPG_TTY=""
fi

## Add GPG_TTY to the environment
export GPG_TTY

## Start the gpg-agent
gpg-connect-agent /bye 1>/dev/null 2>&1

## Configure SSH to use the gpg-agent
test -S "${SSH_AUTH_SOCK:-}" || {
  ## Unset the current ssh-agent PID
  unset SSH_AGENT_PID
  ## Check that gpg-agent was not  started as `gpg-agent --daemon /bin/sh`
  if test "$(( gnupg_SSH_AUTH_SOCK_by ))" -ne "$$"; then
    ## Set SSH_AUTH_SOCK to the agent's socket then add it to the environment
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  fi
}



# vi:ft=sh:et:sts=2:sw=2:ts=8
