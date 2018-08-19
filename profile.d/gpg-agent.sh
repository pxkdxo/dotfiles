#!/usr/bin/env sh

## Set GPG_TTY to the current tty
if tty --silent; then
  export GPG_TTY="$(tty)"
else
  export GPG_TTY=''
fi

## Start gpg-agent
gpg-connect-agent /bye 2>/dev/null
