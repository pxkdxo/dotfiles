#!/usr/bin/env sh
#
# pythonrc.sh: see if we have a PYTHONSTARTUP file to execute on interactive startup

if test -d "${XDG_CONFIG_HOME:-${HOME}/.config}"/python; then
  if test -f "${XDG_CONFIG_HOME:-${HOME}/.config}"/python/pythonrc.py; then
    export PYTHONSTARTUP="${XDG_CONFIG_HOME:-${HOME}/.config}"/python/pythonrc.py
  elif test -f "${XDG_CONFIG_HOME:-${HOME}/.config}"/python/rc.py; then
    export PYTHONSTARTUP="${XDG_CONFIG_HOME:-${HOME}/.config}"/python/rc.py
  elif test -f "${XDG_CONFIG_HOME:-${HOME}/.config}"/python/pythonrc; then
    export PYTHONSTARTUP="${XDG_CONFIG_HOME:-${HOME}/.config}"/python/pythonrc
  elif test -f "${XDG_CONFIG_HOME:-${HOME}/.config}"/python/rc; then
    export PYTHONSTARTUP="${XDG_CONFIG_HOME:-${HOME}/.config}"/python/rc
  fi
elif test -d "${XDG_CONFIG_HOME:-${HOME}/.config}"; then
  if test -f "${XDG_CONFIG_HOME:-${HOME}/.config}"/pythonrc.py; then
    export PYTHONSTARTUP="${XDG_CONFIG_HOME:-${HOME}/.config}"/pythonrc.py
  elif test -f "${XDG_CONFIG_HOME:-${HOME}/.config}"/rc.py; then
    export PYTHONSTARTUP="${XDG_CONFIG_HOME:-${HOME}/.config}"/rc.py
  elif test -f "${XDG_CONFIG_HOME:-${HOME}/.config}"/pythonrc; then
    export PYTHONSTARTUP="${XDG_CONFIG_HOME:-${HOME}/.config}"/pythonrc
  elif test -f "${XDG_CONFIG_HOME:-${HOME}/.config}"/rc; then
    export PYTHONSTARTUP="${XDG_CONFIG_HOME:-${HOME}/.config}"/rc
  fi
elif test -d "${XDG_DATA_HOME:-${HOME}/.local/share}/python"; then
  if test -f "${XDG_DATA_HOME:-${HOME}/.local/share}/python/pythonrc.py"; then
    export PYTHONSTARTUP="${XDG_DATA_HOME:-${HOME}/.local/share}/python/pythonrc.py"
  elif test -f "${XDG_DATA_HOME:-${HOME}/.local/share}/python/rc.py"; then
    export PYTHONSTARTUP="${XDG_DATA_HOME:-${HOME}/.local/share}/python/rc.py"
  elif test -f "${XDG_DATA_HOME:-${HOME}/.local/share}/python/pythonrc"; then
    export PYTHONSTARTUP="${XDG_DATA_HOME:-${HOME}/.local/share}/python/pythonrc"
  elif test -f "${XDG_DATA_HOME:-${HOME}/.local/share}/python/rc"; then
    export PYTHONSTARTUP="${XDG_DATA_HOME:-${HOME}/.local/share}/python/rc"
  fi
elif test -d ~/; then
  if test -f ~/.pythonrc.py; then
    export PYTHONSTARTUP=~/.pythonrc.py
  elif test -f ~/.rc.py; then
    export PYTHONSTARTUP=~/.rc.py
  elif test -f ~/.pythonrc; then
    export PYTHONSTARTUP=~/.pythonrc
  elif test -f ~/.rc; then
    export PYTHONSTARTUP=~/.rc
  fi
fi

# vim:ft=sh
