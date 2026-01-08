#!/usr/bin/env sh
# command-not-found.sh: command-not-found hooks for bash and zsh

if test -n "${ZSH_NAME}"; then
  __command_not_found_func="command_not_found_handler"
  __command_not_found_pkgfile_script="/usr/share/doc/pkgfile/command-not-found.zsh"
  __sh_ext="zsh"
elif test -n "${BASH}"; then
  __command_not_found_func="command_not_found_handle"
  __command_not_found_pkgfile_init="/usr/share/doc/pkgfile/command-not-found.bash"
fi

# Platforms with a built-in command-not-found handler init file
for file in \
  "${__command_not_found_pkgfile_init}" \
  /opt/homebrew/Library/Homebrew/command-not-found/handler.sh \
  /usr/local/Homebrew/Library/Homebrew/command-not-found/handler.sh \
  /home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/command-not-found/handler.sh \
  /opt/homebrew/Library/Taps/homebrew/homebrew-command-not-found/handler.sh \
  /usr/local/Homebrew/Library/Taps/homebrew/homebrew-command-not-found/handler.sh \
  /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-command-not-found/handler.sh
do
  if test -r "${file}"; then
    . -- "${file}"
    unset file
    return 0
  fi
done
unset file

# Platforms with manual command_not_found_handler() setup

# Debian and derivatives: https://launchpad.net/ubuntu/+source/command-not-found
if test -x /usr/lib/command-not-found || test -x /usr/share/command-not-found/command-not-found; then
  eval "${__command_not_found_func}()"'
  {
    if test -x /usr/lib/command-not-found; then
      /usr/lib/command-not-found -- "$1"
      return "$?"
    elif test -x /usr/share/command-not-found/command-not-found; then
      /usr/share/command-not-found/command-not-found -- "$1"
      return "$?"
    else
      printf "%s: command not found: %s\n" "${0##*/}" "$1" >&2
      return 127
    fi
  }'
fi

# Fedora: https://fedoraproject.org/wiki/Features/PackageKitCommandNotFound
if test -x /usr/libexec/pk-command-not-found; then
  eval "${__command_not_found_func}()"'
    if test -S /var/run/dbus/system_bus_socket && test -x /usr/libexec/packagekitd; then
      /usr/libexec/pk-command-not-found "$@"
      return "$?"
    fi

    printf "zsh: command not found: %s\n" "$1" >&2
    return 127
  }'
fi

# NixOS: https://github.com/NixOS/nixpkgs/tree/master/nixos/modules/programs/command-not-found
if test -x /run/current-system/sw/bin/command-not-found; then
  eval "${__command_not_found_func}()"'
    /run/current-system/sw/bin/command-not-found "$@"
  }'
fi

# Termux: https://github.com/termux/command-not-found
if test -x /data/data/com.termux/files/usr/libexec/termux/command-not-found; then
  eval "${__command_not_found_func}()"'
    /data/data/com.termux/files/usr/libexec/termux/command-not-found "$1"
  }'
fi

# SUSE and derivates: https://www.unix.com/man-page/suse/1/command-not-found/
if test -x /usr/bin/command-not-found; then
  eval "${__command_not_found_func}()"'
    /usr/bin/command-not-found "$1"
  }'
fi

# vim:ft=sh
