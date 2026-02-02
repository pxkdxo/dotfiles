#!/usr/bin/env sh
# python-macos.sh: macOS Python executable and library paths

case "$(uname -s 2> /dev/null)" in
  [Dd]arwin*)
    for name in ~/Library/Python/*/bin; do
      if test -d "${name}"; then
        case ":${PATH}:" in
          *":${name}:"*)
            ;;
          *) export PATH="${PATH:+${PATH}:}${name}"
            ;;
        esac
      fi
    done
    unset name
  ;;
esac

# vim:ft=sh
