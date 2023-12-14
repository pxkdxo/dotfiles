#!/usr/bin/env sh
# bin-local.sh: local bin directory path config

if test -d /Users/"$(id -un)"/.local/bin
then
  case ":${PATH}:" in
    *:"/Users/$(id -un)/.local/bin":*) ;;
    *) export PATH="${PATH:+${PATH}:}/Users/$(id -un)/.local/bin" ;;
  esac
fi
if test -d /Users/"$(id -un)"/.bin
then
  case ":${PATH}:" in
    *:"/Users/$(id -un)/.bin":*) ;;
    *) export PATH="${PATH:+${PATH}:}/Users/$(id -un)/.bin" ;;
  esac
fi
if test -d /Users/"$(id -un)"/bin
then
  case ":${PATH}:" in
    *:"/Users/$(id -un)/bin":*) ;;
    *) export PATH="${PATH:+${PATH}:}/Users/$(id -un)/bin" ;;
  esac
fi

# vim:ft=sh
