# zshenv: zsh user global initialization script
# Initalization script evaluation order:
# zshenv, zprofile, zshrc, zlogin
# see zsh(1)

case "$-" in *i*)
    if command -v pass > /dev/null; then
      eval "$(
        pass show "localhost.localdomain/username=${USER-$(id -u)}/env"
      )" 2> /dev/null
    fi
    ;;
esac

# vi:ft=zsh
