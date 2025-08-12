#!/usr/bin/env sh
# cargo.sh: cargo environment config

for directory in \
    "${CARGO_HOME-}" \
    "${XDG_DATA_HOME:+"${XDG_DATA_HOME}/cargo"}" \
    "${HOME}/.local/share/cargo" \
    "${HOME}/.local/opt/cargo" \
    "${HOME}/.local/cargo" \
    "${HOME}/.cargo" \
    "${HOME}/cargo"
do
    if test -d "${directory}/bin"; then
        case ":${PATH}:" in
            *:"${directory}/bin":*)
                ;;
            *) export PATH="${PATH:+${PATH}:}${directory}/bin"
                ;;
        esac
        if test -z "${CARGO_HOME+X}"; then
            export CARGO_HOME="${directory}"
        fi
    fi
done

# vim:ft=sh
