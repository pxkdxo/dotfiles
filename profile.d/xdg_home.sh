#!/usr/bin/env sh
# xdg_home.sh : set missing xdg home vars

export XDG_DATA_HOME="${XDG_DATA_HOME-${HOME}/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME-${HOME}/.config}"

# vim:ft=sh
