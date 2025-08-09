# Find fzf and add it to the PATH
if [[ -d "${FZF_BASE:-}" ]]; then
  export FZF_BASE="${FZF_BASE:-}"
elif [[ -d "${XDG_DATA_HOME:-${HOME}/.local/share}/fzf" ]]; then
  export FZF_BASE="${XDG_DATA_HOME:-${HOME}/.local/share}/fzf"
elif [[ -d "${HOME}/.local/opt/fzf" ]]; then
  export FZF_BASE="${HOME}/.local/opt/fzf"
elif [[ -d '/usr/local/share/fzf' ]]; then
  export FZF_BASE='/usr/local/share/fzf'
elif [[ -d '/usr/share/fzf' ]]; then
  export FZF_BASE='/usr/share/fzf'
elif [[ -d '/opt/fzf' ]]; then
  export FZF_BASE='/opt/fzf'
else
  unset -v FZF_BASE
fi
if [[ -n "${FZF_BASE}" ]]; then
  case ":${FZF_BASE}/bin:" in
    *":${PATH}:"*)
      # FF_BASE/bin is already in PATH, do nothing
      ;;
    *)
      export PATH="${PATH:+${PATH}:}${FZF_BASE}/bin"
      ;;
  esac
fi

