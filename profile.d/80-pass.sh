#!/usr/bin/env sh
# pass.sh: pass environment config
# see pass(1)
# Cross-platform: macOS (id -F), Linux (getent), POSIX fallback (USER)

# Resolve user identifier for GPG key matching (used when .gpg-id absent)
_pass_resolve_name() {
  if id -F >/dev/null 2>&1; then
    id -F 2>/dev/null
  elif command -v getent >/dev/null 2>&1; then
    _gecos=$(getent passwd "${USER:-$(id -un 2>/dev/null)}" 2>/dev/null)
    if test -n "${_gecos}"; then
      printf '%s\n' "${_gecos}" | cut -d: -f5 | cut -d, -f1
    else
      printf '%s\n' "${USER:-$(id -un 2>/dev/null)}"
    fi
    unset _gecos
  else
    printf '%s\n' "${USER:-$(id -un 2>/dev/null)}"
  fi
}

# Only configure when we can identify the user
_pass_user="${USER:-$(id -un 2>/dev/null)}"
if test -n "${_pass_user}"; then
  # Set password store key from .gpg-id when present (fast path)
  if test -z "${PASSWORD_STORE_KEY:-}" && test -f "${PASSWORD_STORE_DIR:-${HOME}/.password-store}/.gpg-id"; then
    read -r PASSWORD_STORE_KEY < "${PASSWORD_STORE_DIR:-${HOME}/.password-store}/.gpg-id"
    if test -n "${PASSWORD_STORE_KEY:-}"; then
      export PASSWORD_STORE_KEY
    fi
  elif test -z "${PASSWORD_STORE_KEY:-}"; then
    # Defer gpg lookup until first pass invocation (literal match via grep -F)
    _pass_gpg_pending=1
    pass() {
      if test "${_pass_gpg_pending:-0}" -eq 1; then
        _pass_gpg_pending=0
        _pn="$(_pass_resolve_name | head -1)"
        _pu="$(printf '%s\n' "${USER:-$(id -un 2>/dev/null)}" | head -1)"
        if test -n "${_pu}"; then
          _uids=$(gpg --list-secret-keys --with-colons 2>/dev/null | grep "^uid:")
          _matched=""
          if test -n "${_pn}"; then
            _matched=$(printf '%s\n' "${_uids}" | grep -F -m 1 "${_pn}" 2>/dev/null)
          fi
          if test -z "${_matched}" && test -n "${_pu}"; then
            _matched=$(printf '%s\n' "${_uids}" | grep -F -m 1 "${_pu}" 2>/dev/null)
          fi
          if test -n "${_matched}"; then
            PASSWORD_STORE_KEY=$(printf '%s\n' "${_matched}" | cut -f 10 -d :)
            if test -n "${PASSWORD_STORE_KEY:-}"; then
              export PASSWORD_STORE_KEY
            fi
          fi
        fi
      fi
      command pass "$@"
    }
  fi
  # OpenKeychain compat.
  export PASSWORD_STORE_GPG_OPTS='--no-throw-keyids'
fi
unset _pass_user
