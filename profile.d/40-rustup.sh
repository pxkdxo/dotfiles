#!/usr/bin/env sh
# rustup.sh: rustup environment config

if test -n "${RUSTUP_HOME:-}"; then
  export RUSTUP_HOME
  case ":${PATH}:" in
    *:"${RUSTUP_HOME}/bin":*) ;;
    *) export PATH="${RUSTUP_HOME}/bin${PATH:+:${PATH}}" ;;
  esac
elif test -d "${HOME}/.local/share/rustup"; then
  export RUSTUP_HOME="${HOME}/.local/share/rustup"
  case ":${PATH}:" in
    *:"${RUSTUP_HOME}/bin":*) ;;
    *) export PATH="${RUSTUP_HOME}/bin${PATH:+:${PATH}}" ;;
  esac
elif test -d "${HOME}/.local/opt/rustup"; then
  export RUSTUP_HOME="${HOME}/.local/opt/rustup"
  case ":${PATH}:" in
    *:"${RUSTUP_HOME}/bin":*) ;;
    *) export PATH="${RUSTUP_HOME}/bin${PATH:+:${PATH}}" ;;
  esac
elif test -d "${HOME}/.rustup"; then
  case ":${PATH}:" in
    *:"${RUSTUP_HOME}/bin":*) ;;
    *) export PATH="${RUSTUP_HOME}/bin${PATH:+:${PATH}}" ;;
  esac
elif command -v brew > /dev/null &&
  RUSTUP_HOME="$(brew --prefix --quiet --installed rustup 2> /dev/null)/cabal"
then
  export RUSTUP_HOME
  case ":${PATH}:" in
    *:"${RUSTUP_HOME}/bin":*) ;;
    *) export PATH="${RUSTUP_HOME}/bin${PATH:+:${PATH}}" ;;
  esac
else
  unset RUSTUP_HOME
fi

# vim:ft=sh
