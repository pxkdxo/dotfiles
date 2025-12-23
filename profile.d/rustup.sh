#!/usr/bin/env sh
# rustup.sh: rustup environment config

if test -d "${RUSTUP_HOME-}"
then
  case ":${PATH}:" in
    *:"${RUSTUP_HOME}/bin":*) ;;
    *) export PATH="${PATH:+${PATH}:}${RUSTUP_HOME}/bin" ;;
  esac
elif test -d "${HOME}/.local/share/rustup"
then
  case ":${PATH}:" in
    *:"${HOME}/.local/share/rustup/bin":*) ;;
    *) export PATH="${PATH:+${PATH}:}${HOME}/.local/share/rustup/bin" ;;
  esac
elif test -d "${HOME}/.local/rustup"
then
  case ":${PATH}:" in
    *:"${HOME}/.local/rustup/bin":*) ;;
    *) export PATH="${PATH:+${PATH}:}${HOME}/.local/rustup/bin" ;;
  esac
elif test -d "${HOME}/.rustup"
then
  case ":${PATH}:" in
    *:"${HOME}/.rustup/bin":*) ;;
    *) export PATH="${PATH:+${PATH}:}${HOME}/.rustup/bin" ;;
  esac
elif test -d "${HOME}/rustup"
then
  case ":${PATH}:" in
    *:"${HOME}/rustup/bin":*) ;;
    *) export PATH="${PATH:+${PATH}:}${HOME}/rustup/bin" ;;
  esac
fi

# vim:ft=sh
