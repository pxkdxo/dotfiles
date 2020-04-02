# rust.sh: rust environment config

if test -d "${CARGO_HOME-}"
then
  export PATH="${CARGO_HOME}/bin${PATH:+:${PATH}}"
elif test -d "${HOME}/.local/share/cargo"
then
  export PATH="${HOME}/.local/share/cargo/bin${PATH:+:${PATH}}"
elif test -d "${HOME}/.cargo"
then
  export PATH="${HOME}/.cargo/bin${PATH:+:${PATH}}"
fi

# vim:ft=sh

# vim:ft=sh
