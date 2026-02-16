#!/usr/bin/env sh
# xdg_base_dirs.sh: Ensure standard XDG base directories are set

export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"
# export TMPDIR="${TMPDIR:-${XDG_STATE_HOME:-}/tmp}"

# vim:ft=sh
