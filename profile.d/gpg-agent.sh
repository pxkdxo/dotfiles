#!/usr/bin/env sh

## Set GPG_TTY to the current tty
if tty --silent; then
  GPG_TTY="$(tty)"
else
  GPG_TTY=""
fi

## Add GPG_TTY to the environment
export GPG_TTY

## Start gpg-agent
gpg-connect-agent /bye 1> /dev/null 2>&1
