#!/usr/bin/env sh
# ~/.profile.d/homebrew.sh: Homebrew environment setup

# Set up Homebrew environment variables and PATH from a cached `brew shellenv`,
# regenerated when brew is newer than the cache. Like brew, apply nothing when
# brew's bin and sbin already lead PATH.
brew_bin="$(command -v brew)"
if test -z "${brew_bin}"; then
  for brew_bin in \
    "${XDG_DATA_HOME:-${HOME}/.local/share}/homebrew/bin/brew" \
    "${HOME}/.local/opt/homebrew/bin/brew" \
    "${HOME}/.local/homebrew/bin/brew" \
    "${HOME}/.homebrew/bin/brew"; do
    test -x "${brew_bin}" && break
    brew_bin=
  done
fi
if test -n "${brew_bin}"; then
  brew_prefix="${brew_bin%/bin/brew}"
  case "${PATH}:" in
    "${brew_prefix}/bin:${brew_prefix}/sbin:"*) ;;
    *)
      if test -n "${ZSH_VERSION-}"; then
        brew_shell="zsh"
      elif test -n "${BASH_VERSION-}"; then
        brew_shell="bash"
      else
        brew_shell="sh"
      fi
      brew_env="${XDG_CACHE_HOME:-${HOME}/.cache}/brew-shellenv.${brew_shell}"
      if ! test -s "${brew_env}" || test "${brew_bin}" -nt "${brew_env}"; then
        mkdir -p "${brew_env%/*}" 2> /dev/null
        if "${brew_bin}" shellenv "${brew_shell}" > "${brew_env}.$$" 2> /dev/null && test -s "${brew_env}.$$"; then
          mv -f "${brew_env}.$$" "${brew_env}"
        fi
        rm -f "${brew_env}.$$"
      fi
      if test -r "${brew_env}"; then
        # shellcheck disable=SC1090
        . "${brew_env}"
      fi
      unset brew_shell brew_env
      ;;
  esac
  unset brew_prefix
fi
unset brew_bin

# Push this stuff back to the front if it wasn't already there
if test -d ~/.local/bin; then
  path_push ~/.local/bin
fi
if test -n "${HOMEBREW_REPOSITORY:-}"; then
  path_push "${HOMEBREW_REPOSITORY}/sbin"
  path_push "${HOMEBREW_REPOSITORY}/bin"
fi
# vim:ft=sh
