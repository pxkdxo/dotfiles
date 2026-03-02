#!/usr/bin/env sh
# go.sh: go environment config

if test -d "${GOPATH-}"; then
  export GOPATH
elif test -d "${XDG_DATA_HOME:-${HOME}/.local/share}/go"; then
  export GOPATH="${XDG_DATA_HOME:-${HOME}/.local/share}/go${GOPATH:+:${GOPATH}}"
elif test -d "${HOME}/.local/opt/go"; then
  export GOPATH="${HOME}/.local/opt/go${GOPATH:+:${GOPATH}}"
elif test -d "${HOME}/.local/go"; then
  export GOPATH="${HOME}/.local/go${GOPATH:+:${GOPATH}}"
elif test -d "${HOME}/.go"; then
  export GOPATH="${HOME}/.go${GOPATH:+:${GOPATH}}"
else
  unset GOPATH
fi

if test -d "${GOBIN-}"; then
  export GOBIN
elif test -d "${XDG_DATA_HOME:-${HOME}/.local/share}/go"; then
  export GOBIN="${GOBIN:-${XDG_DATA_HOME:-${HOME}/.local/share}/go/bin}"
elif test -d "${HOME}/.local/opt/go"; then
  export GOBIN="${GOBIN:-${HOME}/.local/opt/go/bin}"
elif test -d "${HOME}/.local/go"; then
  export GOBIN="${GOBIN:-${HOME}/.local/go/bin}"
elif test -d "${HOME}/.go"; then
  export GOBIN="${GOBIN:-${HOME}/.go/bin}"
else
  unset GOBIN
fi
if test -f "${GOENV-}"; then
  export GOENV
elif test -d "${XDG_CONFIG_HOME:-${HOME}/.config}/go"; then
  export GOENV="${XDG_CONFIG_HOME:-${HOME}/.config}/go/env"
elif test -d "${HOME}/.go"; then
  export GOENV="${HOME}/.go/env"
else
  unset GOENV
fi

if test -n "${GOENV-}" && command -v go > /dev/null; then
  if test -n "${GOBIN-}"; then
    _go_current=$(go env GOBIN 2>/dev/null) || _go_current=""
    if test "${_go_current:-}" != "${GOBIN}"; then
      go env -w GOBIN="${GOBIN}"
    fi
    unset _go_current
  fi
  if test -n "${GOPATH-}"; then
    _go_current=$(go env GOPATH 2>/dev/null) || _go_current=""
    if test "${_go_current:-}" != "${GOPATH}"; then
      go env -w GOPATH="${GOPATH}"
    fi
    unset _go_current
  fi
fi

if test -n "${GOBIN-}"; then
  case ":${PATH}:" in
    *:"${GOBIN}":*) ;;
    *) export PATH="${GOBIN}${PATH:+:${PATH}}" ;;
  esac
fi

# vim:ft=sh
