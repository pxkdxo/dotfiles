#!/usr/bin/env sh
# python-macos.sh: python path config

case "$(uname)" in
  [Dd]arwin*)
    for directory in /Users/"$(id -un)"/Library/Python/*/bin
    do
      case ":${PATH}:" in
        *:"${directory}":*) ;;
        *) export PATH="${PATH:+${PATH}:}${directory}" ;;
      esac
    done
    ;;
esac
unset directory

# vim:ft=sh
