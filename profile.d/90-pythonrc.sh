#!/usr/bin/env sh
#
# pythonrc.sh: point PYTHONSTARTUP at the first readable candidate rc file.
#
# A flat first-match scan, so a present-but-empty ~/.config/python directory no
# longer short-circuits the XDG_DATA_HOME and legacy locations (the old nested
# elif ladder branched on directory existence first and fell through silently).

for _pythonrc in \
  "${XDG_CONFIG_HOME:-${HOME}/.config}/python/pythonrc.py" \
  "${XDG_CONFIG_HOME:-${HOME}/.config}/python/rc.py" \
  "${XDG_CONFIG_HOME:-${HOME}/.config}/python/pythonrc" \
  "${XDG_CONFIG_HOME:-${HOME}/.config}/python/rc" \
  "${XDG_CONFIG_HOME:-${HOME}/.config}/pythonrc.py" \
  "${XDG_CONFIG_HOME:-${HOME}/.config}/rc.py" \
  "${XDG_CONFIG_HOME:-${HOME}/.config}/pythonrc" \
  "${XDG_CONFIG_HOME:-${HOME}/.config}/rc" \
  "${XDG_DATA_HOME:-${HOME}/.local/share}/python/pythonrc.py" \
  "${XDG_DATA_HOME:-${HOME}/.local/share}/python/rc.py" \
  "${XDG_DATA_HOME:-${HOME}/.local/share}/python/pythonrc" \
  "${XDG_DATA_HOME:-${HOME}/.local/share}/python/rc" \
  "${HOME}/.pythonrc.py" \
  "${HOME}/.rc.py" \
  "${HOME}/.pythonrc" \
  "${HOME}/.rc"
do
  if test -f "${_pythonrc}"; then
    export PYTHONSTARTUP="${_pythonrc}"
    break
  fi
done
unset _pythonrc

# vim:ft=sh
