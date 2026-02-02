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
    *:"${HOME}/.local/share/cabal/bin":*) ;;
    *) export PATH="${HOME}/.local/share/cabal/bin${PATH:+:${PATH}}" ;;
  esac
elif test -d "${HOME}/.local/opt/cabal"; then
  export CABAL_HOME="${HOME}/.local/opt/cabal"
  case ":${PATH}:" in
    *:"${HOME}/.local/opt/cabal/bin":*) ;;
    *) export PATH="${HOME}/.local/opt/cabal/bin${PATH:+:${PATH}}" ;;
  esac
elif test -d "${HOME}/.local/cabal"; then
  export CABAL_HOME="${HOME}/.local/cabal"
  case ":${PATH}:" in
    *:"${HOME}/.local/cabal/bin":*) ;;
    *) export PATH="${HOME}/.local/cabal/bin${PATH:+:${PATH}}" ;;
  esac
elif test -d "${HOME}/.cabal"; then
  export CABAL_HOME="${HOME}/.cabal"
  case ":${PATH}:" in
    *:"${HOME}/.cabal/bin":*) ;;
    *) export PATH="${HOME}/.cabal/bin${PATH:+:${PATH}}" ;;
  esac
fi

# (PATH=)@<=("?)(\$\{PATH:\+("?)\$\{PATH}:\3})([^ "]+)\1/\1\4\${PATH:+:\${PATH}}\1/
# vim:ft=sh
