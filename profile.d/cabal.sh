#!/usr/bin/env sh
# cabal.sh: cabal path config

for directory in \
    "${CABAL_HOME-}" \
    "${XDG_DATA_HOME:+"${XDG_DATA_HOME}/cabal"}" \
    "${HOME}/.local/share/cabal" \
    "${HOME}/.local/opt/cabal" \
    "${HOME}/.local/cabal" \
    "${HOME}/.cabal" \
    "${HOME}/cabal"
do
    if test -d "${directory}/bin"; then
        case ":${PATH}:" in
            *:"${directory}/bin":*) ;;
            *) export PATH="${PATH:+${PATH}:}${directory}/bin" ;;
        esac
        if test -z "${CABAL_HOME+X}"; then
            export CABAL_HOME="${directory}"
        fi
    fi
done

# vim:ft=sh
