# rust.sh: rust environment config

if test -d "${CARGO_HOME-}"
then
  export PATH="${PATH:+${PATH}:}${CARGO_HOME}/bin"
elif test -d "${HOME}/.local/share/cargo"
then
  export PATH="${PATH:+${PATH}:}${HOME}/.local/share/cargo/bin"
elif test -d "${HOME}/.cargo"
then
  export PATH="${PATH:+${PATH}:}${HOME}/.cargo/bin"
fi

# vim:ft=sh
