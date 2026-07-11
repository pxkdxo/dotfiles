#!/usr/bin/env sh
# gpg-agent.sh: gpg-agent config
# see gpg-agent(1)

# Point pinentry at the tty that owns this login shell. Login-shell only by
# design: the passphrase prompt lands on the tty of the most recent login,
# rather than following every command the way ohmyzsh's gpg-agent preexec
# hook did (a gpg-connect-agent fork before each command). zsh provides $TTY
# without a fork; bash and plain sh pay one tty(1) call.
if test -t 0; then
  GPG_TTY="${TTY:-$(tty)}"
  export GPG_TTY
fi

# Fix for passphrase prompt on the correct tty
if command -v gpg-connect-agent > /dev/null; then
  gpg-connect-agent updatestartuptty /bye > /dev/null 2>&1
fi

# Configure SSH to use gpg-agent (if supported)
if command -v gpgconf > /dev/null; then
  gpg_agent_opts="$(gpgconf --list-options gpg-agent 2> /dev/null | tr -s '\n' ':')"

  case ":${gpg_agent_opts}:" in
    *:enable-ssh-support:*)
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
      ;;
  esac
  unset gpg_agent_opts
fi

# vim:ft=sh
