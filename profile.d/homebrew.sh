#!/usr/bin/env sh
# ~/.profile.d/homebrew.sh: Homebrew environment setup

if test -d "${XDG_DATA_HOME:-${HOME}/.local/share}/homebrew/bin"
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
elif test -d "/opt/homebrew/bin"
then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif test -d "/usr/local/bin" && test -x "/usr/local/bin/brew"
then
  eval "$(/usr/local/bin/brew shellenv)"
elif test -d "/usr/bin" && test -x "/usr/bin/brew"
then
  eval "$(/usr/bin/brew shellenv)"
fi

# vim:ft=sh
