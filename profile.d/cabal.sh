# cabal.sh: cabal environment config

if test -d "${CABAL_HOME-}"
then
  export PATH="${CABAL_HOME}/bin${PATH:+:${PATH}}"
elif test -d "${HOME}/.local/share/cabal"
then
  export PATH="${HOME}/.local/share/cabal/bin${PATH:+:${PATH}}"
elif test -d "${HOME}/.cabal"
then
  export PATH="${HOME}/.cabal/bin${PATH:+:${PATH}}"
fi

# vim:ft=sh
