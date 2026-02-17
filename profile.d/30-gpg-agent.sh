#!/usr/bin/env sh
# gpg-agent.sh: gpg-agent config
# see gpg-agent(1)

# Fix for passphrase prompt on the correct tty
if command -v gpg-connect-agent > /dev/null; then
  gpg-connect-agent updatestartuptty /bye > /dev/null 2>&1
fi

# Configure SSH to use gpg-agent (if supported)
if command -v gpgconf > /dev/null; then
  gpg_agent_opts="$(gpgconf --list-options gpg-agent 2>/dev/null | tr -s '\n' ':')"
  
  case ":${gpg_agent_opts}:" in
    *:enable-ssh-support:*)
      unset SSH_AGENT_PID
      ssh_socket="$(gpgconf --list-dirs agent-ssh-socket 2>/dev/null)"
      
      if test -n "${ssh_socket}" && \
         test "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne "$$" && \
         test -S "${ssh_socket}"; then
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
