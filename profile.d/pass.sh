#!/usr/bin/env sh
# pass.sh: pass environment config
# see pass(1)

# Set PASSWORD_STORE_KEY if not already set
if test -z "${PASSWORD_STORE_KEY:-}"; then
  gpg_id_file="${PASSWORD_STORE_DIR:-${HOME}/.password-store}/.gpg-id"
  if test -r "${gpg_id_file}"; then
    read -r PASSWORD_STORE_KEY < "${gpg_id_file}" || true
    # Trim whitespace
    PASSWORD_STORE_KEY="${PASSWORD_STORE_KEY#"${PASSWORD_STORE_KEY%%[![:space:]]*}"}"
    PASSWORD_STORE_KEY="${PASSWORD_STORE_KEY%"${PASSWORD_STORE_KEY##*[![:space:]]}"}"
  fi
  unset gpg_id_file
fi

# Export PASSWORD_STORE_KEY if we have a value
if test -n "${PASSWORD_STORE_KEY:-}"; then
  export PASSWORD_STORE_KEY
  
  # Set PASSWORD_STORE_SIGNING_KEY if not already set
  if test -z "${PASSWORD_STORE_SIGNING_KEY:-}" && command -v gpg > /dev/null; then
    gpg_output="$(gpg --list-secret-keys --with-fingerprint --with-colons "=${PASSWORD_STORE_KEY}" 2>/dev/null)"
    
    if test -n "${gpg_output}"; then
      fingerprint="$(printf '%s' "${gpg_output}" | grep -E -m 1 '^fpr:' | cut -f 10 -d ':')"
      
      if test -n "${fingerprint}"; then
        export PASSWORD_STORE_SIGNING_KEY="${fingerprint}"
      else
        unset PASSWORD_STORE_SIGNING_KEY
      fi
      unset fingerprint
    else
      unset PASSWORD_STORE_SIGNING_KEY
    fi
    unset gpg_output
  elif test -n "${PASSWORD_STORE_SIGNING_KEY:-}"; then
    export PASSWORD_STORE_SIGNING_KEY
  fi
else
  unset PASSWORD_STORE_KEY
  unset PASSWORD_STORE_SIGNING_KEY
fi

# vim:ft=sh
