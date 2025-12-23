#!/usr/bin/env sh
# ~/.profile.d/homebrew.sh: Homebrew environment setup

if test -n "${HOMEBREW_HOME:-}" && test -d "${HOMEBREW_HOME}/bin"
then
  eval "$("${HOMEBREW_HOME}/bin/brew" shellenv)"
elif test -d "${XDG_DATA_HOME:-${HOME}/.local/share}/homebrew/bin"
then
  export HOMEBREW_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/homebrew"
  eval "$("${HOMEBREW_HOME}/bin/brew" shellenv)"
elif test -d "${HOME}/.local/opt/homebrew/bin"
then
  eval "$("${HOME}/.local/opt/homebrew/bin/brew" shellenv)"
elif test -d "${HOME}/.homebrew/bin"
then
  eval "$("${HOME}/.homebrew/bin/brew" shellenv)"
elif test -d "${HOME}/homebrew/bin"
then
  eval "$("${HOME}/homebrew/bin/brew" shellenv)"
elif test -d "/opt/homebrew/bin"
then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif test -d "/usr/local/bin" && test -x "/usr/local/bin/brew"
then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# vim:ft=sh
