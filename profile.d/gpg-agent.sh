# gpg-agent.sh : gpg-agent config
# see gpg-agent(1)

AGENT_SOCK="$(gpgconf --list-dirs agent-socket)"

# --use-standard-socket will work from version 2 upwards
if ! test -S "${AGENT_SOCK}"
then
  gpg-agent --daemon --use-standard-socket 1> /dev/null 2>&1
fi

# Export the current terminal
GPG_TTY="${TTY:-$(tty)}"
export GPG_TTY

# Configure SSH to use gpg-agent
unset -v SSH_AGENT_PID
if test "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne "$$"
then
  SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  export SSH_AUTH_SOCK
fi

# if REPLY=$(tty)
# then
#   export GPG_TTY="${REPLY}"
# fi
# 
# # Refresh gpg-agent
# gpg-connect-agent > /dev/null 2>&1 updatestartuptty /bye
# 
# # --use-standard-socket will work from version 2 upwards
# if REPLY=$(gpgconf --list-dirs agent-socket) && test -S "${REPLY}"
# then
#   export AGENT_SOCK="${REPLY}"
# else
#   gpg-agent --daemon --use-standard-socket
# fi
# 
# # Configure SSH to use gpg-agent
# if ! test -S "${SSH_AUTH_SOCK-}"
# then
#   if test "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne "$$"
#   then
#     if REPLY=$(gpgconf --list-dirs agent-ssh-socket)
#     then
#       export SSH_AUTH_SOCK="${REPLY}"
#     fi
#     unset -v SSH_AGENT_PID
#   fi
# fi

# vi:ft=sh
