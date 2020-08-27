# go.sh: go environment config

if test -n "${GOBIN}"; then
  case ":${PATH}:" in
    *:"${GOBIN}":*) ;;
    *) export PATH="${PATH:+${PATH}:}${GOBIN}" ;;
  esac
elif test -n "${GOPATH}"; then
  case ":${PATH}:" in
    *:"${GOPATH}/bin":*) ;;
    *) export PATH="${PATH:+${PATH}:}${GOPATH}/bin" ;;
  esac
elif test -d "${HOME}/.local/share/go"; then
  case ":${PATH}:" in
    *:"${HOME}/.local/share/go/bin":*) ;;
    *) export PATH="${PATH:+${PATH}:}${HOME}/.local/share/go/bin" ;;
  esac
elif test -d "${HOME}/.local/go"; then
  case ":${PATH}:" in
    *:"${HOME}/.local/go/bin":*) ;;
    *) export PATH="${PATH:+${PATH}:}${HOME}/.local/go/bin" ;;
  esac
elif test -d "${HOME}/.go"; then
  case ":${PATH}:" in
    *:"${HOME}/.go/bin":*) ;;
    *) export PATH="${PATH:+${PATH}:}${HOME}/.go/bin" ;;
  esac
elif test -d "${HOME}/go"; then
  case ":${PATH}:" in
    *:"${HOME}/go/bin":*) ;;
    *) export PATH="${PATH:+${PATH}:}${HOME}/go/bin" ;;
  esac
fi

# vim:ft=sh
