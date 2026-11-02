#!/usr/bin/env sh
# ~/.profile.d/homebrew.sh: Homebrew environment setup

# Set up Homebrew environment variables and PATH
if command -v brew >/dev/null; then
  eval "$(brew shellenv)"
elif test -d "${XDG_DATA_HOME:-${HOME}/.local/share}/homebrew/bin"; then
  eval "$("${XDG_DATA_HOME:-${HOME}/.local/share}/homebrew/bin/brew" shellenv)"
elif test -d "${HOME}/.local/opt/homebrew/bin"; then
  eval "$("${HOME}/.local/opt/homebrew/bin/brew" shellenv)"
elif test -d "${HOME}/.local/homebrew/bin"; then
  eval "$("${HOME}/.local/homebrew/bin/brew" shellenv)"
elif test -d "${HOME}/.homebrew/bin"; then
  eval "$("${HOME}/.homebrew/bin/brew" shellenv)"
fi

# Push this stuff back to the front if it wasn't already there
if test -d ~/.local/bin; then
  path_push ~/.local/bin
fi
if test -n "${HOMEBREW_REPOSITORY:-}"; then
  path_push "${HOMEBREW_REPOSITORY}/sbin"
  path_push "${HOMEBREW_REPOSITORY}/bin"
fi
# vim:ft=sh
