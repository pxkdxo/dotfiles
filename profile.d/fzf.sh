#!/usr/bin/env sh
# ~/.profile.d/fzf.sh: look for an fzf installation and append it to the PATH

if test -d "${FZF_BASE:-}"
then
  export FZF_BASE="${FZF_BASE:-}"
elif test -d "${XDG_DATA_HOME:-${HOME}/.local/share}/fzf/bin"
then
  export FZF_BASE="${XDG_DATA_HOME:-${HOME}/.local/share}/fzf"
elif test -d "${HOME}/.local/opt/fzf/bin"
then
  export FZF_BASE="${HOME}/.local/opt/fzf"
elif test -d '/usr/local/share/fzf/bin'
then
  export FZF_BASE='/usr/local/share/fzf'
elif test -d '/usr/share/fzf/bin'
then
  export FZF_BASE='/usr/share/fzf'
elif test -d '/opt/fzf/bin'
then
  export FZF_BASE='/opt/fzf'
else
  unset -v FZF_BASE
fi
if test -d "${FZF_BASE:-}"
then
  case ":${PATH}:" in
    *:"${FZF_PATH}":*) ;;
    *) export PATH="${PATH:+${PATH}:}${FZF_BASE}/bin" ;;
  esac
fi
