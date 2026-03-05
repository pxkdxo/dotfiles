#!/usr/bin/env sh
# cabal.sh: cabal path config

if test -d "${CABAL_HOME-}"; then
  export CABAL_HOME
  case ":${PATH}:" in
    *:"${CABAL_HOME}/bin":*) ;;
    *) export PATH="${CABAL_HOME}/bin${PATH:+:${PATH}}" ;;
  esac
elif test -d "${HOME}/.local/share/cabal"; then
  export CABAL_HOME="${HOME}/.local/share/cabal"
  case ":${PATH}:" in
    *:"${CABAL_HOME}/bin":*) ;;
    *) export PATH="${CABAL_HOME}/bin${PATH:+:${PATH}}" ;;
  esac
elif test -d "${HOME}/.local/opt/cabal"; then
  export CABAL_HOME="${HOME}/.local/opt/cabal"
  case ":${PATH}:" in
    *:"${CABAL_HOME}/bin":*) ;;
    *) export PATH="${CABAL_HOME}/bin${PATH:+:${PATH}}" ;;
  esac
elif test -d "${HOME}/.cabal"; then
  export CABAL_HOME="${HOME}/.cabal"
  case ":${PATH}:" in
    *:"${CABAL_HOME}/bin":*) ;;
    *) export PATH="${CABAL_HOME}/bin${PATH:+:${PATH}}" ;;
  esac
elif CABAL_HOME="${HOMEBREW_PREFIX:-$(brew --prefix 2> /dev/null)}/opt/cabal-install" && test -d "${CABAL_HOME}"; then
  export CABAL_HOME
  case ":${PATH}:" in
    *:"${CABAL_HOME}/bin":*) ;;
    *) export PATH="${CABAL_HOME}/bin${PATH:+:${PATH}}" ;;
  esac
else
  unset CABAL_HOME
fi

# vim:ft=sh
