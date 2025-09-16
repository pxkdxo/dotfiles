#!/usr/bin/env sh
# gpg-agent.sh: gpg-agent config
# see gpg-agent(1)

if command -v gpgconf > /dev/null
then
  AGENT_SOCK="$(gpgconf --list-dirs agent-socket)"

  # '--use-standard-socket' should work from version 2 onwards
  if ! test -S "${AGENT_SOCK}"; then
    gpg-agent --daemon --use-standard-socket 1> /dev/null 2>&1
  fi

  # Export the current terminal
  GPG_TTY="${TTY:-$(tty)}"
  export GPG_TTY

  # Configure SSH to use gpg-agent
  unset -v SSH_AGENT_PID
  if test "${GNUPG_SSH_AUTH_SOCK_BY:-0}" -ne "$$"; then
    SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    export SSH_AUTH_SOCK
  fi
fi

# vi:ft=sh
