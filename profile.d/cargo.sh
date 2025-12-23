#!/usr/bin/env sh
# cargo.sh: cargo environment config

if test -d "${CARGO_HOME-}"
then
  case ":${PATH}:" in
    *:"${CARGO_HOME}/bin":*) ;;
    *) export PATH="${PATH:+${PATH}:}${CARGO_HOME}/bin" ;;
  esac
elif test -d "${HOME}/.local/share/cargo"
then
  case ":${PATH}:" in
    *:"${HOME}/.local/share/cargo/bin":*) ;;
    *) export PATH="${PATH:+${PATH}:}${HOME}/.local/share/cargo/bin" ;;
  esac
elif test -d "${HOME}/.local/cargo"
then
  case ":${PATH}:" in
    *:"${HOME}/.local/cargo/bin":*) ;;
    *) export PATH="${PATH:+${PATH}:}${HOME}/.local/cargo/bin" ;;
  esac
elif test -d "${HOME}/.cargo"
then
  case ":${PATH}:" in
    *:"${HOME}/.cargo/bin":*) ;;
    *) export PATH="${PATH:+${PATH}:}${HOME}/.cargo/bin" ;;
  esac
elif test -d "${HOME}/cargo"
then
  case ":${PATH}:" in
    *:"${HOME}/cargo/bin":*) ;;
    *) export PATH="${PATH:+${PATH}:}${HOME}/cargo/bin" ;;
  esac
fi

# vim:ft=sh
