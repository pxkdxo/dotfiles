#!/usr/bin/env sh
# ~/.profile.d/macos-cursor.sh: macOS Cursor.app path setup

case "$(uname -s)" in
  # Add Cursor.app to PATH if it exists
  Darwin*|darwin*)
    if test -x "${HOME}/Applications/Cursor.app/Contents/Resources/app/bin/code"
    then
      case ":${PATH}:" in
        *:"${HOME}/Applications/Cursor.app/Contents/Resources/app/bin":*) ;;
        *) export PATH="${HOME}/Applications/Cursor.app/Contents/Resources/app/bin${PATH:+:${PATH}}" ;;
      esac
    elif test -x "/Applications/Cursor.app/Contents/Resources/app/bin/code"
    then
      case ":${PATH}:" in
        *:"/Applications/Cursor.app/Contents/Resources/app/bin":*) ;;
        *) export PATH="/Applications/Cursor.app/Contents/Resources/app/bin${PATH:+:${PATH}}" ;;
      esac
    fi
    ;;
esac

# vim:ft=sh
