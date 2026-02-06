#!/usr/bin/env sh
# go.sh: go environment config

if test -n "${GOPATH}"; then
  export GOPATH
elif test -d "${XDG_DATA_HOME:-${HOME}/.local/share}/go"; then
  export GOPATH="${XDG_DATA_HOME:-${HOME}/.local/share}/go${GOPATH:+:${GOPATH}}"
elif test -d "${HOME}/.local/opt/go"; then
  export GOPATH="${HOME}/.local/opt/go${GOPATH:+:${GOPATH}}"
elif test -d "${HOME}/.local/go"; then
  export GOPATH="${HOME}/.local/go${GOPATH:+:${GOPATH}}"
elif test -d "${HOME}/.go"; then
  export GOPATH="${HOME}/.go${GOPATH:+:${GOPATH}}"
fi

if test -n "${GOBIN}"; then
  export GOBIN
elif test -d "${XDG_DATA_HOME:-${HOME}/.local/share}/go"; then
  export GOBIN="${GOBIN:-${XDG_DATA_HOME:-${HOME}/.local/share}/go/bin}"
elif test -d "${HOME}/.local/opt/go"; then
  export GOBIN="${GOBIN:-${HOME}/.local/opt/go/bin}"
elif test -d "${HOME}/.local/go"; then
  export GOBIN="${GOBIN:-${HOME}/.local/go/bin}"
elif test -d "${HOME}/.go"; then
  export GOBIN="${GOBIN:-${HOME}/.go/bin}"
fi
if test -n "${GOBIN}"; then
  case ":${PATH}:" in
    *:"${GOBIN}":*) ;;
    *) export PATH="${GOBIN}${PATH:+:${PATH}}" ;;
  esac
fi

if test -n "${GOENV}"; then
  export GOENV
elif test -d "${XDG_CONFIG_HOME:-${HOME}/.config}/go"; then
  export GOENV="${XDG_CONFIG_HOME:-${HOME}/.config}/go/env"
elif test -d "${HOME}/.go"; then
  export GOENV="${HOME}/.go/env"
fi
if command -v go > /dev/null; then
  if test -n "${GOBIN}"; then
    go env -w GOBIN="${GOBIN}"
  fi
  if test -n "${GOPATH}"; then
    go env -w GOPATH="${GOPATH}"
  fi
fi

# vim:ft=sh
