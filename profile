# ~/.profile: login shell initialization script
# see sh(1), bash(1), dash(1), ...

# Initialize terminal
if test -t 0 && command -v tput 1> /dev/null
then
    tput init
fi

# Set file creation mode mask
if test "${UID:-$(id -u)}" -eq 0
then
    umask 0002
else
    umask 0022
fi

# Import user environment from systemd
while read -r REPLY
do
    case "${REPLY%%=*}" in
        [!A-Za-z_]*|?*[!A-Za-z0-9_]*)
            ;;
        ?*) eval 'test -n "${'"${REPLY%%=*}"'+_}" || export '"${REPLY}"
            ;;
    esac
done << @STOP
$(systemctl --user show-environment 2>/dev/null)
@STOP

# If HOME is unset or NULL, set it
if test -z "${HOME-}"
then
    if IFS=':' read -r _ _ _ _ _ HOME _ && test -n "${HOME}"
    then
        export HOME
    else
        exit 1
    fi
fi << @STOP
$(getent passwd -- "${UID:-$(id -u)}" 2>/dev/null)
@STOP

# Prepend executable paths
for _ in  "${HOME}/.local/bin" "${HOME}/.bin" "${HOME}/bin"
do
    if test -d "$_"
    then
        case ":${PATH-}:" in
            *":$_:"*)
                ;;
            *)  export PATH="${_}${PATH:+:${PATH}}"
                ;;
        esac
    fi
done

# Load additional profile config
if test -d "${HOME}/.profile.d"
then
    for _ in "${HOME}/.profile.d"/*.sh
    do
        if test -f "$_" && test -r "$_"
        then
            . "$_"
        fi
    done
fi

## Termcap should be dead; kill it
unset -v TERMCAP

## Man is much better at figuring this out than we are
unset -v MANPATH

# vi:ft=sh
