#!/usr/bin/env bash
# ~/.profile.d/homebrew.sh: Homebrew environment setup

if test -d "${HOMEBREW_HOME:-}"
then
  eval "$("${HOMEBREW_HOME}/bin/brew" shellenv)"
elif test -d "${XDG_DATA_HOME:-"${HOME}/.local/share"}/homebrew/bin"
then
  export HOMEBREW_HOME="${}"
  eval "$("${XDG_DATA_HOME:-"${HOME}/.local/share"}/homebrew/bin/brew" shellenv)"
elif test -d ~/.local/opt/homebrew/bin
then
  eval "$(~/.local/opt/homebrew/bin/brew shellenv)"
elif test -d ~/.homebrew/bin
then
  eval "$(~/.homebrew/bin/brew shellenv)"
elif test -d ~/homebrew/bin
then
  eval "$(~/homebrew/bin/brew shellenv)"
fi
