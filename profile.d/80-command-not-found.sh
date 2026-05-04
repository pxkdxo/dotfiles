#!/usr/bin/env sh
# command-not-found.sh: command-not-found hooks for bash and zsh

# Guard for other shells
if test -n "${BASH_VERSION-}${ZSH_VERSION-}"; then
  __command_not_found_configured=""

  if test -n "${HOMEBREW_REPOSITORY-}" || HOMEBREW_REPOSITORY="$(brew --repository)" && test -f "${HOMEBREW_REPOSITORY}/Library/Homebrew/command-not-found/handler.sh"; then
    # Use homebrew if we have it...
    . "${HOMEBREW_REPOSITORY}/Library/Homebrew/command-not-found/handler.sh"
  # Debian and derivatives (https://launchpad.net/ubuntu/+source/command-not-found)
  elif test -x /usr/lib/command-not-found; then
    __command_not_found_configured=1
    __command_not_found_func() {
      /usr/lib/command-not-found -- "$@" || :
      return "$?"
    }
  elif test -x /usr/share/command-not-found/command-not-found; then
    __command_not_found_configured=1
    __command_not_found_func() {
      /usr/share/command-not-found/command-not-found -- "$@" || :
      return "$?"
    }
    # NixOS (https://github.com/NixOS/nixpkgs/tree/master/nixos/modules/programs/command-not-found)
  elif test -x /run/current-system/sw/bin/command-not-found; then
    __command_not_found_configured=1
    __command_not_found_func() {
      /run/current-system/sw/bin/command-not-found "$@"
      return "$?"
    }
  # Fedora (https://fedoraproject.org/wiki/Features/PackageKitCommandNotFound)
  elif test -x /usr/libexec/pk-command-not-found && test -x /usr/libexec/packagekitd; then
    __command_not_found_configured=1
    __command_not_found_func() {
      if test -S /var/run/dbus/system_bus_socket; then
        /usr/libexec/pk-command-not-found "$@" || :
        return "$?"
      else
        printf "%s: command not found: %s\n" "${0##*/}" "$*" >&2
        return "$?"
      fi
    }
  # Termux (https://github.com/termux/command-not-found)
  elif test -x /data/data/com.termux/files/usr/libexec/termux/command-not-found; then
    __command_not_found_configured=1
    __command_not_found_func() {
      /data/data/com.termux/files/usr/libexec/termux/command-not-found "$@"
    }
  # SUSE and derivatives (https://www.unix.com/man-page/suse/1/command-not-found/)
  elif test -x /usr/bin/command-not-found; then
    __command_not_found_configured=1
    __command_not_found_func() {
      /usr/bin/command-not-found "$1"
      return "$?"
    }
  elif test -n "${ZSH_VERSION}" && test -f /usr/share/doc/pkgfile/command-not-found.zsh; then
    . "/usr/share/doc/pkgfile/command-not-found.zsh"
  elif test -n "${BASH_VERSION}" && test -f /usr/share/doc/pkgfile/command-not-found.bash; then
    . "/usr/share/doc/pkgfile/command-not-found.bash"
  fi
  unset __command_not_found_configured
fi

# vim:ft=sh
