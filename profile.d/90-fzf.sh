#!/usr/bin/env sh
# ~/.profile.d/fzf.sh: look for an fzf installation and append it to the PATH
# This script also includes comprehensive fzf extensions for enhanced productivity
# Requires: fzf, ripgrep, fd, bat (optional but recommended)

if test -d "${FZF_BASE:-}"; then
  export FZF_BASE
elif test -d "${XDG_DATA_HOME:-${HOME}/.local/share}/fzf"; then
  export FZF_BASE="${XDG_DATA_HOME:-${HOME}/.local/share}/fzf"
elif test -d "${HOME}/.local/opt/fzf"; then
  export FZF_BASE="${HOME}/.local/opt/fzf"
elif test -d "${HOME}/.local/homebrew/opt/fzf"; then
  export FZF_BASE="${HOME}/.local/homebrew/opt/fzf"
elif test -d '/usr/local/share/fzf'; then
  export FZF_BASE='/usr/local/share/fzf'
elif test -d "${HOME}/.fzf"; then
  export FZF_BASE="${HOME}/.fzf"
else
  unset FZF_BASE
fi

# Only define extensions when fzf is available
if command -v fzf > /dev/null 2>&1; then

  # Helper: Get default editor
  _fzf_get_editor() {
    printf '%s\n' "${EDITOR:-${VISUAL:-$(command -v editor || command -v nvim || command -v vim || command -v vi)}}"
  }

  # Helper: Get clipboard command
  _fzf_get_clipboard() {
    if case "$(uname -s)" in
      Darwin* | darwin*)
        command -v pbcopy
        ;;
      Linux*Android* | Linux*android* | linux*android*)
        command -v termux-clipboard-set
        ;;
      Cygwin* | cygwin* | Msys* | msys*)
        echo 'cat > /dev/clipboard'
        ;;
      *)
        false
        ;;
    esac then
      :
    elif test "${XDG_SESSION_TYPE:-}" = "wayland" \
      && test -n "${WAYLAND_DISPLAY:-}" \
      && command -v wl-copy; then
      echo 'wl-copy -n > /dev/null 2>&1'
    elif test "${XDG_SESSION_TYPE:-}" = "x11" \
      && test -n "${DISPLAY:-}" \
      && command -v xsel > /dev/null; then
      echo 'xsel --clipboard --input'
      return
    elif test "${XDG_SESSION_TYPE:-}" = "x11" \
      && test -n "${DISPLAY:-}" \
      && command -v xclip > /dev/null; then
      echo 'xclip -selection clipboard -in > /dev/null 2>&1'
    elif command -v lemonade > /dev/null; then
      echo 'lemonade copy'
    elif command -v doitclient > /dev/null; then
      echo 'doitclient wclip'
    elif command -v win32yank > /dev/null; then
      echo 'win32yank -i'
    elif test -n "${TMUX:-}" \
      && command -v tmux > /dev/null; then
      echo 'tmux load-buffer -w'
    else
      return 1
    fi
  }

  # Helper: Get open command
  _fzf_get_open() {
    case "$(uname -s)" in
      Darwin) echo "open" ;;
      Linux) echo "xdg-open" ;;
      *) echo "echo" ;;
    esac
  }

  # Helper: Get preview command for files
  _fzf_get_file_preview() {
    _file="$1"
    if command -v bat > /dev/null; then
      echo "bat --color=always --paging=never --style=numbers,grid --line-range :500 -- ${_file}"
    elif command -v cat > /dev/null; then
      echo "cat -- ${_file}"
    else
      echo "file --mime --brief --dereference -- ${_file}"
    fi
    unset _file
  }

  # Helper: Get directory preview
  _fzf_get_dir_preview() {
    if command -v eza > /dev/null; then
      printf '%s\n' 'eza --color=always --icons --git --group-directories-first --long --all -- {}'
    elif command -v lsd > /dev/null; then
      printf '%s\n' 'lsd --color=always --icon=always --long --all -- {}'
    elif command -v tree > /dev/null; then
      printf '%s\n' 'tree -L 3 -C --dirsfirst -- {}'
    else
      case "$(uname -s)" in
        Darwin*) printf '%s\n' 'ls -lah -G -- {}' ;;
        *) printf '%s\n' 'ls -lah --color=always -- {}' ;;
      esac
    fi
  }

  # Helper: Trim leading newline from multi-line header string
  _fzf_header() {
    printf '%s\n' "$1" | sed '1d'
  }

  # Helper: Find files (and symlinks) - cross-platform fd/find
  _fzf_find_files() {
    _path="${1:-.}"
    if command -v fd > /dev/null; then
      fd --hidden --follow --type f --type l -- "${_path}"
    else
      find "${_path}" \( -type f -o -type l \)
    fi
  }

  # Helper: Find directories - cross-platform fd/find
  _fzf_find_dirs() {
    _path="${1:-.}"
    if command -v fd > /dev/null; then
      fd --hidden --follow --type d -- "${_path}"
    else
      find "${_path}" -type d
    fi
  }

  # Helper: Find files only (no symlinks) - for cp/mv/rm
  _fzf_find_files_only() {
    _path="${1:-.}"
    if command -v fd > /dev/null; then
      fd --hidden --follow --type f -- "${_path}"
    else
      find "${_path}" -type f
    fi
  }

  # Source extensions (process, files, git, docker, kube, history, ssh, env, etc.)
  for _profile_d in \
    "${XDG_CONFIG_HOME:-${HOME}/.config}/profile.d" \
    "${HOME}/.local/etc/profile.d"; do
    if test -r "${_profile_d}/90-fzf-extensions.sh"; then
      # shellcheck disable=SC1090
      . "${_profile_d}/90-fzf-extensions.sh"
      break
    fi
  done
  unset _profile_d

fi
# end fzf availability guard

# vi:et:ft=sh:sts=2:sw=2:ts=2:tw=0
