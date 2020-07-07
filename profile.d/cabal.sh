# cabal.sh: cabal path config

if test -d "${CABAL_HOME}"; then
  export PATH="${PATH:+${PATH}:}${CABAL_HOME}/bin"
elif test -d "${HOME}/.local/share/cabal"; then
  export PATH="${PATH:+${PATH}:}${HOME}/.local/share/cabal/bin"
elif test -d "${HOME}/.cabal"; then
  export PATH="${PATH:+${PATH}:}${HOME}/.cabal/bin"
fi

# vim:ft=sh
