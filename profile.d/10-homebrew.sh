#!/usr/bin/env sh
# ~/.profile.d/homebrew.sh: Homebrew environment setup

if command -v brew > /dev/null
then
  eval "$(brew shellenv)"
elif test -d "${XDG_DATA_HOME:-${HOME}/.local/share}/homebrew/bin"
then
  eval "$("${XDG_DATA_HOME:-${HOME}/.local/share}/homebrew/bin/brew" shellenv)"
elif test -d "${HOME}/.local/opt/homebrew/bin"
then
  eval "$("${HOME}/.local/opt/homebrew/bin/brew" shellenv)"
elif test -d "${HOME}/.local/homebrew/bin"
then
  eval "$("${HOME}/.local/homebrew/bin/brew" shellenv)"
elif test -d "${HOME}/.homebrew/bin"
then
  eval "$("${HOME}/.homebrew/bin/brew" shellenv)"
fi

# vim:ft=sh
