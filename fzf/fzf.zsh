# Setup fzf
# ---------
for __fzf_dir in \
  "${FZF_BASE-}" \
  "${XDG_DATA_HOME:-${HOME}/.local/share}/fzf" \
  "${HOME}/.local/opt/fzf" \
  "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/fzf"; do
  if [[ -d "${__fzf_dir}/bin" ]]; then
    case ":${PATH}:" in
      *":${__fzf_dir}/bin:"*) ;;
      *) PATH="${PATH:+${PATH}:}${__fzf_dir}/bin" ;;
    esac
    break
  fi
done
unset __fzf_dir

source <(fzf --zsh)
