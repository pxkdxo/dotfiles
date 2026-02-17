#!/usr/bin/env sh
# pass.sh: pass environment config
# see pass(1)

# Set password store key
if test -z "${PASSWORD_STORE_KEY}"; then
 # Read key identifier
  read -r PASSWORD_STORE_KEY < "${PASSWORD_STORE_DIR:-${HOME}/.password-store}/.gpg-id" || true
fi 2> /dev/null
if test -n "${PASSWORD_STORE_KEY}"; then
  export PASSWORD_STORE_KEY
fi

# Set password store signing key
if test -n "${PASSWORD_STORE_KEY}" && test -z "${PASSWORD_STORE_SIGNING_KEY}" && command -v gpg > /dev/null; then
  PASSWORD_STORE_SIGNING_KEY="$(
    gpg --list-secret-keys --with-fingerprint --with-colons "=${PASSWORD_STORE_KEY}" |
    grep -E -m 1 '^fpr:' |
    cut -f 10 -d ':'
  )"
fi 2> /dev/null
if test -n "${PASSWORD_STORE_SIGNING_KEY}"; then
  export PASSWORD_STORE_SIGNING_KEY
fi

# vim:ft=sh
