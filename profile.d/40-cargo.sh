#!/usr/bin/env sh
# cargo.sh: cargo environment config

if test -n "${CARGO_HOME-}"
then
  case ":${PATH}:" in
    *:"${CARGO_HOME}/bin":*) ;;
    *) export PATH="${CARGO_HOME}/bin${PATH:+:${PATH}}" ;;
  esac
elif test -d "${HOME}/.local/share/cargo"; then
  export CARGO_HOME="${HOME}/.local/share/cargo"
  case ":${PATH}:" in
    *:"${HOME}/.local/share/cargo/bin":*) ;;
    *) export PATH="${HOME}/.local/share/cargo/bin${PATH:+:${PATH}}" ;;
  esac
elif test -d "${HOME}/.local/opt/cargo"; then
  export CARGO_HOME="${HOME}/.local/opt/cargo"
  case ":${PATH}:" in
    *:"${HOME}/.local/share/opt/bin":*) ;;
    *) export PATH="${HOME}/.local/opt/cargo/bin${PATH:+:${PATH}}" ;;
  esac
elif test -d "${HOME}/.local/cargo"; then
  export CARGO_HOME="${HOME}/.local/cargo"
  case ":${PATH}:" in
    *:"${HOME}/.local/cargo/bin":*) ;;
    *) export PATH="${HOME}/.local/cargo/bin${PATH:+:${PATH}}" ;;
  esac
elif test -d "${HOME}/.cargo"; then
  export CARGO_HOME="${HOME}/.cargo"
  case ":${PATH}:" in
    *:"${HOME}/.cargo/bin":*) ;;
    *) export PATH="${HOME}/.cargo/bin${PATH:+:${PATH}}" ;;
  esac
fi

# vim:ft=sh
