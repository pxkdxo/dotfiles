#!/usr/bin/env sh
# cabal.sh: cabal path config

if test -n "${CABAL_HOME}"; then
  case ":${PATH}:" in
    *:"${CABAL_HOME}/bin":*) ;;
    *) export PATH="${PATH:+${PATH}:}${CABAL_HOME}/bin" ;;
  esac
elif test -d "${HOME}/.local/share/cabal"; then
  case ":${PATH}:" in
    *:"${HOME}/.local/share/cabal/bin":*) ;;
    *) export PATH="${PATH:+${PATH}:}${HOME}/.local/share/cabal/bin" ;;
  esac
elif test -d "${HOME}/.local/cabal"; then
  case ":${PATH}:" in
    *:"${HOME}/.local/cabal/bin":*) ;;
    *) export PATH="${PATH:+${PATH}:}${HOME}/.local/cabal/bin" ;;
  esac
elif test -d "${HOME}/.cabal"; then
  case ":${PATH}:" in
    *:"${HOME}/.cabal/bin":*) ;;
    *) export PATH="${PATH:+${PATH}:}${HOME}/.cabal/bin" ;;
  esac
elif test -d "${HOME}/cabal"; then
  case ":${PATH}:" in
    *:"${HOME}/cabal/bin":*) ;;
    *) export PATH="${PATH:+${PATH}:}${HOME}/cabal/bin" ;;
  esac
fi

# vim:ft=sh
