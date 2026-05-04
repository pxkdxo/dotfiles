# Setup fzf
# ---------
for __fzf_dir in \
  "${FZF_BASE-}" \
  "${XDG_DATA_HOME:-${HOME}/.local/share}/fzf" \
  "${HOME}/.local/opt/fzf" \
  "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/fzf"; do
  [[ -n "${__fzf_dir}" && -d "${__fzf_dir}/bin" ]] || continue
  case ":${PATH}:" in
    *":${__fzf_dir}/bin:"*) ;;
    *) PATH="${PATH:+${PATH}:}${__fzf_dir}/bin" ;;
  esac
  break
done
unset __fzf_dir

eval "$(fzf --bash)"
