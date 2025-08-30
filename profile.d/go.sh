#!/usr/bin/env sh
# go.sh: go environment config

if test -d "${XDG_CONFIG_HOME:-${HOME}/.config}/go"; then
  export GOENV="${XDG_CONFIG_HOME:-${HOME}/.config}/go/env"
elif test -d "${XDG_DATA_HOME:-${HOME}/.local/share}/go"; then
  export GOENV="${XDG_DATA_HOME:-${HOME}/.local/share}/go/env"
elif test -d "${HOME}/.go"; then
  export GOENV="${HOME}/.go/env"
fi

if test -d "${XDG_DATA_HOME:-${HOME}/.local/share}/go"; then
  export GOBIN="${GOBIN:-${XDG_DATA_HOME:-${HOME}/.local/share}/go/bin}"
  export GOPATH="${XDG_DATA_HOME:-${HOME}/.local/share}/go${GOPATH:+:${GOPATH}}"
fi
if test -d "${HOME}/.local/opt/go"; then
  export GOBIN="${GOBIN:-${HOME}/.local/opt/go/bin}"
  export GOPATH="${HOME}/.local/opt/go${GOPATH:+:${GOPATH}}"
fi
if test -d "${HOME}/.local/go"; then
  export GOBIN="${GOBIN:-${HOME}/.local/go/bin}"
  export GOPATH="${HOME}/.local/go${GOPATH:+:${GOPATH}}"
fi
if test -d "${HOME}/.go"; then
  export GOBIN="${GOBIN:-${HOME}/.go/bin}"
  export GOPATH="${HOME}/.go${GOPATH:+:${GOPATH}}"
fi

if test -n "${GOBIN}"; then
  case ":${PATH}:" in
    *:"${GOBIN}":*) ;;
    *) export PATH="${GOBIN}${PATH:+:${PATH}}" ;;
  esac
fi

if command -v go > /dev/null; then
  if test -n "${GOBIN}"; then
    go env -w GOBIN="${GOBIN:-$(go env GOBIN)}"
  fi
  if test -n "${GOPATH}"; then
    go env -w GOPATH="${GOPATH:-$(go env GOPATH)}"
  fi
fi

# vim:ft=sh
