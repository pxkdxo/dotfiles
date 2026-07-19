#!/usr/bin/env sh
# gpg-agent.sh: gpg-agent config
# see gpg-agent(1)

# Point pinentry at this login shell's tty; the prompt follows the most
# recent login, by design. zsh has $TTY for free; bash/sh fork tty(1) once.
if test -t 0; then
  GPG_TTY="${TTY:-$(tty)}"
  export GPG_TTY
fi

# Fix for passphrase prompt on the correct tty
if command -v gpg-connect-agent > /dev/null; then
  gpg-connect-agent updatestartuptty /bye > /dev/null 2>&1
fi

# Configure SSH to use gpg-agent (if supported). Read enable-ssh-support
# directly from gpg-agent.conf instead of `gpgconf --list-options
# gpg-agent`, which round-trips through gpg-agent's component-query path
# and costs ~600ms here for a value the config file already states.
if command -v gpgconf > /dev/null; then
  gpg_agent_conf="$(gpgconf --list-dirs 2> /dev/null | sed -n 's/^homedir://p')/gpg-agent.conf"

  if test -r "${gpg_agent_conf}" \
    && grep -Eq '^[[:space:]]*enable-ssh-support([[:space:]]|$)' "${gpg_agent_conf}"; then
    unset SSH_AGENT_PID
    ssh_socket="$(gpgconf --list-dirs agent-ssh-socket 2> /dev/null)"

    if test -n "${ssh_socket}" \
      && test "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne "$$" \
      && test -S "${ssh_socket}"; then
      export SSH_AUTH_SOCK="${ssh_socket}"
    else
      unset SSH_AUTH_SOCK
    fi
    unset ssh_socket
  fi
  unset gpg_agent_conf
fi

# vim:ft=sh
