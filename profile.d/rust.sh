# rust.sh: rust environment config

if test -d "${CARGO_HOME:-${HOME}/.cargo/bin}"
then
  export PATH="${CARGO_HOME:-${HOME}/.cargo/bin}${PATH:+:${PATH}}"
fi

# vim:ft=sh
