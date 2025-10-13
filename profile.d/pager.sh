#!/usr/bin/env sh
# pager.sh: configure the PAGER environment variable
# see environ(7) and select-editor(1)

if command -v pager > /dev/null
then
	export PAGER="pager"
elif command -v update-alternatives > /dev/null
then
	unset OLD_IFS
	if test -n "${IFS+X}"
	then
		OLD_IFS="${IFS}"
	fi
	unset IFS
	while read -r REPLY; do
		REPLY="${REPLY#"${REPLY%%[![:blank:]]*}"}"
		REPLY="${REPLY%"${REPLY##*[![:blank:]]}"}"
		if test "${REPLY%%[[:blank:]]*}" = 'Value:'
		then
			if test -x "${REPLY#"${REPLY%%/*}"}"
			then
				export PAGER="${REPLY##*[[:blank:]]}"
				break
			fi
		fi
	done <<-EOF
	$(update-alternatives --query pager 2> /dev/null)
	EOF
	unset REPLY
	if test -n "${OLD_IFS+X}"
	then
		export IFS="${OLD_IFS}"
	fi
	unset OLD_IFS
elif command -v less > /dev/null
then
	export PAGER="less"
fi

# vi:ts=8:noet:sw=8:sts=8:ft=sh
