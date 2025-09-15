#!/usr/bin/env sh
# pass.sh: pass environment config
# see pass(1)

# shellcheck disable=SC2015
{
	# Check if PASSWORD_STORE_KEY is already set
	test -n "${PASSWORD_STORE_KEY}"
} || {
	# If not, try to read it from the .gpg-id file
	test -r "${PASSWORD_STORE_DIR:-${HOME}/.password-store}/.gpg-id" &&
	read -r PASSWORD_STORE_KEY < "${PASSWORD_STORE_DIR:-${HOME}/.password-store}/.gpg-id" &&
	test -n "${PASSWORD_STORE_KEY}"
} && {
	# Export PASSWORD_STORE_KEY :)
	export PASSWORD_STORE_KEY
	{
		# Check if PASSWORD_STORE_SIGNING_KEY is already set
		test -n "${PASSWORD_STORE_SIGNING_KEY}"
	} || {
		{
			# If not, check if gpg is available to help
			command -v gpg > /dev/null
		} && {
			{
				# Try to get the fingerprint of the key referred to PASSWORD_STORE_KEY
				PASSWORD_STORE_SIGNING_KEY="$(gpg --list-secret-keys --with-fingerprint --with-colons "=${PASSWORD_STORE_KEY}")"
			} && {
				# Extract the fingerprint from the gpg output
				read -r PASSWORD_STORE_SIGNING_KEY <<-EOF
				$(grep -E -m 1 '^fpr:' | cut -f 10 -d :)
				EOF
			} <<-EOF
			${PASSWORD_STORE_SIGNING_KEY}
			EOF
		} && {
			# Verify that we have a non-empty fingerprint
			test -n "${PASSWORD_STORE_SIGNING_KEY}"
		}
	} && {
		# Export PASSWORD_STORE_SIGNING_KEY :)
		export PASSWORD_STORE_SIGNING_KEY
	} || {
		# Unset PASSWORD_STORE_SIGNING_KEY if we couldn't find a value for it
		unset PASSWORD_STORE_SIGNING_KEY
	}
} || {
	# Unset PASSWORD_STORE_KEY if we couldn't find a value for it
	unset PASSWORD_STORE_KEY
}

# vi:ts=8:noet:sw=8:sts=8:ft=sh
