#!/usr/bin/env sh
# ~/.profile.d/macos-cursor.sh: macOS Cursor.app path setup

if test "$(uname)" != "Darwin"; then
  return 0
fi

# Add Cursor.app to PATH if it exists
for cursor_path in \
  "/Applications/Cursor.app/Contents/Resources/app/bin" \
  "${HOME}/Applications/Cursor.app/Contents/Resources/app/bin"
do
  if test -x "${cursor_path}/code"; then
    case ":${PATH}:" in
      *":${cursor_path}:"*) ;;
      *) export PATH="${PATH:+${PATH}:}${cursor_path}" ;;
    esac
  fi
done

# vim:ft=sh
