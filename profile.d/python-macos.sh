#!/usr/bin/env sh
# python-macos.sh: macOS Python executable paths

if test "$(uname)" != "Darwin"; then
  return 0
fi

# Add user Python bin directories to PATH
python_user_dir="/Users/$(id -un)/Library/Python"
if test -d "${python_user_dir}"; then
  for directory in "${python_user_dir}"/*/bin; do
    if test -d "${directory}"; then
      case ":${PATH}:" in
        *":${directory}:"*) ;;
        *) export PATH="${PATH:+${PATH}:}${directory}" ;;
      esac
    fi
  done
fi
unset python_user_dir

# vim:ft=sh
