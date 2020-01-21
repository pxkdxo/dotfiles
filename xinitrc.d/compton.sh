#!/usr/bin/env sh
#
# Start compton as a daemon

if command -v compton
then
  pgrep -fxu "${USER:-$(id -un)}" compton || exec compton &
fi 1> /dev/null 2>&1

# vi:ft=sh
