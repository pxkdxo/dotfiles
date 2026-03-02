# ~/.bash_profile: startup script for bash login shells

# Load config for login shells
if [[ -f ~/.profile && -r ~/.profile ]]
then
  source ~/.profile
fi

# Load config for interactive shells
if [[ -f ~/.bashrc && -r ~/.bashrc ]]
then
  source ~/.bashrc
fi

# Upon login at virtual terminal 1, start a graphical session
if [[ -z ${DISPLAY-} ]] && (( XDG_VTNR == 1 ))
then
  case "${XDG_SESSION_TYPE:-}" in
    wayland)
      ;;
    x11)
      if command -v startx >/dev/null; then
        exec startx
      fi
      ;;
  esac
fi

# vi:ft=sh
