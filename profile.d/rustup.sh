#!/usr/bin/env sh
# rustup.sh: rustup environment config

if test -n "${RUSTUP_HOME:-}"
then
  case ":${PATH}:" in
    *:"${RUSTUP_HOME}/bin":*) ;;
    *) export PATH="${RUSTUP_HOME}/bin${PATH:+:${PATH}}" ;;
  esac
elif test -d "${HOME}/.local/share/rustup"
then
  export RUSTUP_HOME="${HOME}/.local/share/rustup"
  case ":${PATH}:" in
    *:"${HOME}/.local/share/rustup/bin":*) ;;
    *) export PATH="${HOME}/.local/share/rustup/bin${PATH:+:${PATH}}" ;;
  esac
elif test -d "${HOME}/.local/opt/rustup"
then
  export RUSTUP_HOME="${HOME}/.local/opt/rustup"
  case ":${PATH}:" in
    *:"${HOME}/.local/opt/rustup/bin":*) ;;
    *) export PATH="${HOME}/.local/opt/rustup/bin${PATH:+:${PATH}}" ;;
  esac
elif test -d "${HOME}/.rustup"
then
  case ":${PATH}:" in
    *:"${HOME}/.rustup/bin":*) ;;
    *) export PATH="${HOME}/.rustup/bin${PATH:+:${PATH}}" ;;
  esac
fi

# vim:ft=sh
