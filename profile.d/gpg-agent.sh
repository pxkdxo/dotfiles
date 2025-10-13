#!/usr/bin/env sh
# gpg-agent.sh: gpg-agent config
# see gpg-agent(1)

# Fix for passphrase prompt on the correct tty
if command -v gpg-connect-agent > /dev/null
then
  gpg-connect-agent updatestartuptty /bye > /dev/null 2>&1
fi

  # Configure SSH to use gpg-agent (if supported)
if command -v gpgconf > /dev/null
then
  case ":$(gpgconf --list-options gpg-agent 2> /dev/null | tr -s '\n' ':'):" in
    *:enable-ssh-support:*)
      unset SSH_AGENT_PID
      if test "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne "$$" && SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
      then
        export SSH_AUTH_SOCK
      else
        unset SSH_AUTH_SOCK
      fi
      ;;
  esac
fi

# vi:ft=sh
