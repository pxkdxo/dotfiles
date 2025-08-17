#!/usr/bin/env sh
# python-macos.sh: python path config

case "$(uname)" in
  [Dd]arwin*)
    if test -d /Users/"$(id -un)"/Library/Python
    then
      for directory in /Users/"$(id -un)"/Library/Python/*/bin
      do
        case ":${PATH}:" in
          *:"${directory}":*) ;;
          *) export PATH="${PATH:+${PATH}:}${directory}" ;;
        esac
      done
    fi
    ;;
esac
unset directory

# vim:ft=sh
