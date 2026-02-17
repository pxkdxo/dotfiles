#!/usr/bin/env sh
# cabal.sh: cabal path config

if test -n "${CABAL_HOME}"; then
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
elif command -v brew > /dev/null &&
  CABAL_HOME="$(brew --prefix --quiet --installed cabal-install 2> /dev/null)/cabal"
then
  export CABAL_HOME
  case ":${PATH}:" in
    *:"${CABAL_HOME}/bin":*) ;;
    *) export PATH="${CABAL_HOME}/bin${PATH:+:${PATH}}" ;;
  esac
else
  unset CABAL_HOME
fi

# vim:ft=sh
