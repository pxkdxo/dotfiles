#!/usr/bin/env sh
# xdg_base_dirs.sh: Ensure the XDG base directories are set

export XDG_STATE_HOME="${XDG_CACHE_HOME:-${HOME}/.local/state}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.local/etc}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.local/state/cache}"
export TMPDIR="${TMPDIR:-${XDG_STATE_HOME:-${HOME}/.local/state}/tmp}"

# vim:ft=sh
