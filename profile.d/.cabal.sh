# cabal.sh: cabal environment config

if test -d "${CABAL_HOME:-${HOME}/.cabal/bin}"
then
  export PATH="${CABAL_HOME:-${HOME}/.cabal/bin}${PATH:+:${PATH}}"
fi

# vim:ft=sh
