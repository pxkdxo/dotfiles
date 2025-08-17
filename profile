# ~/.profile: login shell initialization script
# see bash(1), dash(1), sh(1), zsh(1), ...

# Initialize terminal
if test -t 1; then
  # Initialize term
  if command -v tput 1> /dev/null; then
    tput init || true
  fi
  # Disable start(C-q) and stop(C-s) 
  if command -v stty 1> /dev/null; then
    stty start '^-' stop '^-' || true
  fi
fi

# Termcap is outdated, old, and crusty, kill it.
unset TERMCAP

# Man is much better than us at figuring this out
unset MANPATH

# Set file creation mode mask
if test "${UID:-$(id -u)}" -eq 0; then
  umask 0002
else
  umask 0022
fi

# Prepend executable paths
case ":${PATH}:" in
    *:"${HOME}/.local/bin":*)
        ;;
    *)
        PATH="${PATH:+${PATH}:}${HOME}/.local/bin"
        ;;
esac
case ":${PATH}:" in
    *:"${HOME}/.bin":*)
        ;;
    *)
        PATH="${PATH:+${PATH}:}${HOME}/.bin"
        ;;
esac

# Load additional profile config
if test -d "${HOME}/.profile.d/"; then
  for name in "${HOME}/.profile.d"/*.sh; do
    if test -f "${name}" && test -r "${name}"; then
      . "${name}"
    fi
  done
  unset -v name
fi

# vi:ft=sh
. "/Users/patrick.deyoreo/.local/share/cargo/env"
