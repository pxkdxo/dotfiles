#!/usr/bin/env sh
# ~/.profile.d/fzf.sh: look for an fzf installation and append it to the PATH
# This script also includes comprehensive fzf extensions for enhanced productivity
# Requires: fzf, ripgrep, fd, bat (optional but recommended)

if test -d "${FZF_BASE-}"
then
  export FZF_BASE
elif test -d "${HOME}/.fzf"
then
  export FZF_BASE="${HOME}/.fzf"
elif test -d "${XDG_DATA_HOME:-${HOME}/.local/share}/fzf"
then
  export FZF_BASE="${XDG_DATA_HOME:-${HOME}/.local/share}/fzf"
elif test -d "${HOME}/.local/opt/fzf"
then
  export FZF_BASE="${HOME}/.local/opt/fzf"
elif test -d "${HOME}/.local/homebrew/opt/fzf"
then
  export FZF_BASE="${HOME}/.local/homebrew/opt/fzf"
elif test -d '/usr/local/share/fzf'
then
  export FZF_BASE='/usr/local/share/fzf'
elif test -d '/opt/fzf'
then
  export FZF_BASE='/opt/fzf'
elif test -d '/usr/share/fzf'
then
  export FZF_BASE='/usr/share/fzf'
fi
if test -z "${FZF_BASE+X}"
then
  unset FZF_BASE
fi

# Ensure fzf is available
_fzf_check_installed() {
  if ! command -v fzf > /dev/null; then
    echo "'fzf' is not installed" >&2
    return 1
  fi
}

# Helper: Get default editor
_fzf_get_editor() {
  echo "${EDITOR:-${VISUAL:-vim}}"
}

# Helper: Get clipboard command
_fzf_get_clipboard() {
  if command -v clipcopy > /dev/null; then
    echo "clipcopy"
  elif command -v wl-copy > /dev/null; then
    echo "wl-copy"
  elif command -v xclip > /dev/null; then
    echo "xclip -sel clipboard"
  elif command -v pbcopy > /dev/null; then
    echo "pbcopy"
  else
    echo "cat"
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
    printf '%s\n' 'ls -lah --color=always -- {}'
  fi
}

# ============================================================================
# Process Management
# ============================================================================

# Kill processes with fzf
fzf_kill() {
  _usage='fzf_kill [-s SIGNAL] [SEARCH]'
  _kill_prefix="kill"
  _kill_signal="TERM"
  _search_query=""

  # Parse options
  while getopts ':hs:' _opt; do
    case "${_opt}" in
      h)
        printf 'usage: %s\n' "${_usage}"
        unset _usage _kill_prefix _kill_signal _search_query _opt
        return 0
        ;;
      s)
        _kill_signal="${OPTARG}"
        ;;
      '?')
        echo "fzf_kill: -${OPTARG}: invalid option" >&2
        printf 'usage: %s\n' "${_usage}" >&2
        unset _usage _kill_prefix _kill_signal _search_query _opt
        return 2
        ;;
      ':')
        echo "fzf_kill: -${OPTARG}: missing required argument" >&2
        printf 'usage: %s\n' "${_usage}" >&2
        unset _usage _kill_prefix _kill_signal _search_query _opt
        return 2
        ;;
    esac
  done
  shift "$((OPTIND - 1))"
  _search_query="$*"

  _kill_prefix="${_kill_prefix} -s ${_kill_signal}"

  # Preview command
  if command -v htop > /dev/null; then
    _preview_cmd='htop -p {2} 2>/dev/null || ps -p {2} -o pid,ppid,user,%cpu,%mem,stat,time,command'
  elif command -v top > /dev/null; then
    _preview_cmd='top -p {2} -n 1 2>/dev/null || ps -p {2} -o pid,ppid,user,%cpu,%mem,stat,time,command'
  else
    _preview_cmd='ps -p {2} -o pid,ppid,user,%cpu,%mem,stat,time,command'
  fi

  _header="
  CTRL-R : Reload   TAB : Toggle + ↓   SHIFT-TAB: Toggle + ↑
  CTRL-X : Kill Selected   CTRL-O : Copy PID   RETURN : Print   ESC : Exit"
  _header=$(echo "${_header}" | sed '1d')

  _clipboard_cmd="$(_fzf_get_clipboard)"

  # Build ps command based on OS
  case "$(uname -s)" in
    Darwin)
      _ps_cmd="ps -e -o user,pid,ppid,%cpu,%mem,stat,stime,tt,time,command"
      ;;
    Linux)
      _ps_cmd="ps -e -o user,pid,ppid,%cpu,%mem,stat,stime,tty,time,command"
      ;;
    *)
      _ps_cmd="ps -e -o user,pid,ppid,stat,stime,tt,time,command"
      ;;
  esac

  eval "${_ps_cmd}" | fzf \
    --multi \
    --header-lines=1 \
    --bind="tab:toggle+down" \
    --bind="shift-tab:toggle+up" \
    --bind='enter:accept' \
    --bind="ctrl-r:clear-query+clear-multi+reload(${_ps_cmd})" \
    --bind="ctrl-x:execute-silent(${_kill_prefix} {+2})+clear-multi+print(* Sent ${_kill_signal} to {+2})+accept" \
    --bind="ctrl-o:execute-silent(printf '%s\n' {+2} | ${_clipboard_cmd})" \
    --bind='esc:abort' \
    --preview="${_preview_cmd}" \
    --preview-window='down:25%,nowrap' \
    --layout=reverse \
    --header="${_header}" \
    --query "${_search_query:-}"

  unset _usage _kill_prefix _kill_signal _search_query _opt _preview_cmd _header _clipboard_cmd _ps_cmd
}

# ============================================================================
# File Search & Content
# ============================================================================

# Find files by content using ripgrep
fzf_grep() {
  if ! command -v rg > /dev/null; then
    echo "ripgrep (rg) is not installed" >&2
    return 1
  fi

  _search_path="${1:-.}"

  _rg_cmd="rg --hidden --smart-case --no-heading"
  _open_cmd="$(_fzf_get_open)"
  _editor_cmd="$(_fzf_get_editor)"
  _clipboard_cmd="$(_fzf_get_clipboard)"

  # Preview command
  if command -v bat > /dev/null; then
    _preview_cmd="bat --color=always --paging=never --line-range :10000 --highlight-line {2} -- {1}"
  else
    _preview_cmd="${_rg_cmd} --no-column --no-line-number --colors 'match:bg:black' --colors 'match:fg:green' --passthru -- {q} {1}"
  fi

  _header="
  CTRL-J : Accept Query   CTRL-K : Clear   CTRL-X : Open   ALT-X : Edit
  CTRL-O : Copy Path   CTRL-/: Toggle Preview   ESC : Exit"
  _header=$(echo "${_header}" | sed '1d')

  fzf \
    --ansi \
    --disabled \
    --delimiter ':' \
    --query '' \
    --bind="start:reload:${_rg_cmd} --column --line-number --color=always -- '.*' \"${1:-.}\"" \
    --bind="change:reload:${_rg_cmd} --column --line-number --color=always -- {q} \"${1:-.}\" || true" \
    --bind='ctrl-j:replace-query+print-query' \
    --bind='ctrl-k:kill-line' \
    --bind='ctrl-c:abort' \
    --bind="ctrl-x:execute-silent(${_open_cmd} {1})+abort" \
    --bind="alt-x:execute(${_editor_cmd} {1})+abort" \
    --bind="ctrl-o:execute-silent(printf '%s\n' {1} | ${_clipboard_cmd})" \
    --bind='ctrl-/:toggle-preview' \
    --preview-window='top:60%,+{2}+3/3,~3' \
    --layout='reverse-list' \
    --header="${_header}" \
    --preview="${_preview_cmd} || ${_rg_cmd} --no-column --no-line-number -- {q} {1}"

  unset _search_path _rg_cmd _open_cmd _editor_cmd _clipboard_cmd _preview_cmd _header
}

# Find files (with preview)
fzf_files() {
  _search_path="${1:-.}"
  _editor_cmd="$(_fzf_get_editor)"
  _open_cmd="$(_fzf_get_open)"
  _clipboard_cmd="$(_fzf_get_clipboard)"
  _preview_cmd="$(_fzf_get_file_preview '{}')"
  _dir_preview_cmd="$(_fzf_get_dir_preview)"

  _header="
  CTRL-X : Open   ALT-X : Edit   CTRL-O : Copy Path
  CTRL-D : Enter Directory   CTRL-/: Toggle Preview   ESC : Exit"
  _header=$(echo "${_header}" | sed '1d')

  if command -v fd > /dev/null; then
    _find_cmd="fd --hidden --follow --type f --type l -- \"${_search_path}\""
  else
    _find_cmd="find \"${_search_path}\" -type f -o -type l"
  fi

  _selected=$(eval "${_find_cmd}" | fzf \
    --multi \
    --bind="ctrl-x:execute-silent(${_open_cmd} {})+abort" \
    --bind="alt-x:execute(${_editor_cmd} {})+abort" \
    --bind="ctrl-o:execute-silent(printf '%s\n' {+} | ${_clipboard_cmd})" \
    --bind="ctrl-d:become(${_dir_preview_cmd})" \
    --bind='ctrl-/:toggle-preview' \
    --preview="${_preview_cmd}" \
    --preview-window='right:60%' \
    --header="${_header}")

  if [ -n "${_selected}" ]; then
    printf '%s\n' "${_selected}"
  fi

  unset _search_path _editor_cmd _open_cmd _clipboard_cmd _preview_cmd _dir_preview_cmd _header _find_cmd _selected
}

# Find directories
fzf_dirs() {
  _search_path="${1:-.}"
  _editor_cmd="$(_fzf_get_editor)"
  _clipboard_cmd="$(_fzf_get_clipboard)"
  _preview_cmd="$(_fzf_get_dir_preview)"

  _header="
  RETURN : cd   CTRL-X : Open   ALT-X : Edit in Editor
  CTRL-O : Copy Path   CTRL-/: Toggle Preview   ESC : Exit"
  _header=$(echo "${_header}" | sed '1d')

  if command -v fd > /dev/null; then
    _find_cmd="fd --hidden --follow --type d -- \"${_search_path}\""
  else
    _find_cmd="find \"${_search_path}\" -type d"
  fi

  _selected=$(eval "${_find_cmd}" | fzf \
    --bind="ctrl-x:execute-silent($(_fzf_get_open) {})+abort" \
    --bind="alt-x:execute(${_editor_cmd} {})+abort" \
    --bind="ctrl-o:execute-silent(printf '%s\n' {} | ${_clipboard_cmd})" \
    --bind='ctrl-/:toggle-preview' \
    --preview="${_preview_cmd}" \
    --preview-window='right:60%' \
    --header="${_header}")

  if [ -n "${_selected}" ]; then
    cd "${_selected}" || return 1
  fi

  unset _search_path _editor_cmd _clipboard_cmd _preview_cmd _header _find_cmd _selected
}

# ============================================================================
# Git Integration
# ============================================================================

# Select git branches
fzf_git_branch() {
  if ! command -v git > /dev/null; then
    echo "git is not installed" >&2
    return 1
  fi

  _editor_cmd="$(_fzf_get_editor)"
  _clipboard_cmd="$(_fzf_get_clipboard)"

  _header="
  RETURN : Checkout   CTRL-X : Delete   ALT-X : View Log
  CTRL-O : Copy Branch Name   CTRL-/: Toggle Preview   ESC : Exit"
  _header=$(echo "${_header}" | sed '1d')

  _branches=$(git branch --all --sort=-committerdate | sed 's/^[* ] //' | sed 's/remotes\///' | sort -u)

  _selected=$(printf '%s\n' "${_branches}" | fzf \
    --bind="ctrl-x:execute-silent(git branch -D {} 2>/dev/null || git branch -dr {} 2>/dev/null)+reload(git branch --all --sort=-committerdate | sed 's/^[* ] //' | sed 's/remotes\///' | sort -u)" \
    --bind="alt-x:execute(git log --oneline --graph --decorate {} | ${_editor_cmd} -)+abort" \
    --bind="ctrl-o:execute-silent(printf '%s\n' {} | ${_clipboard_cmd})" \
    --bind='ctrl-/:toggle-preview' \
    --preview="git log --oneline --graph --decorate --color=always {}" \
    --preview-window='right:50%' \
    --header="${_header}")

  if [ -n "${_selected}" ]; then
    # Handle remote branches
    case "${_selected}" in
      remotes/*)
        _branch_name=$(echo "${_selected}" | sed 's|^remotes/[^/]*/||')
        git checkout -b "${_branch_name}" "${_selected}" 2>/dev/null || git checkout "${_branch_name}"
        unset _branch_name
        ;;
      *)
        git checkout "${_selected}"
        ;;
    esac
  fi

  unset _editor_cmd _clipboard_cmd _header _branches _selected
}

# Select git commits
fzf_git_commit() {
  if ! command -v git > /dev/null; then
    echo "git is not installed" >&2
    return 1
  fi

  _editor_cmd="$(_fzf_get_editor)"
  _clipboard_cmd="$(_fzf_get_clipboard)"

  _header="
  RETURN : Show   CTRL-X : Checkout   ALT-X : Edit Commit
  CTRL-O : Copy Hash   CTRL-/: Toggle Preview   ESC : Exit"
  _header=$(echo "${_header}" | sed '1d')

  _commits=$(git log --oneline --graph --decorate --color=always --all)

  _selected=$(printf '%s\n' "${_commits}" | fzf \
    --ansi \
    --bind="ctrl-x:execute-silent(git checkout {1})+abort" \
    --bind="alt-x:execute(git show {1} | ${_editor_cmd} -)+abort" \
    --bind="ctrl-o:execute-silent(printf '%s\n' {1} | ${_clipboard_cmd})" \
    --bind='ctrl-/:toggle-preview' \
    --preview="git show --stat --color=always {1}" \
    --preview-window='right:60%' \
    --header="${_header}")

  if [ -n "${_selected}" ]; then
    _hash=$(echo "${_selected}" | awk '{print $1}')
    git show "${_hash}"
    unset _hash
  fi

  unset _editor_cmd _clipboard_cmd _header _commits _selected
}

# Select git files
fzf_git_files() {
  if ! command -v git > /dev/null; then
    echo "git is not installed" >&2
    return 1
  fi

  _editor_cmd="$(_fzf_get_editor)"
  _open_cmd="$(_fzf_get_open)"
  _clipboard_cmd="$(_fzf_get_clipboard)"
  _preview_cmd="$(_fzf_get_file_preview '{}')"

  _header="
  RETURN : Open   CTRL-X : Open System   ALT-X : Edit
  CTRL-O : Copy Path   CTRL-/: Toggle Preview   ESC : Exit"
  _header=$(echo "${_header}" | sed '1d')

  _files=$(git ls-files)

  _selected=$(printf '%s\n' "${_files}" | fzf \
    --multi \
    --bind="ctrl-x:execute-silent(${_open_cmd} {})+abort" \
    --bind="alt-x:execute(${_editor_cmd} {})+abort" \
    --bind="ctrl-o:execute-silent(printf '%s\n' {+} | ${_clipboard_cmd})" \
    --bind='ctrl-/:toggle-preview' \
    --preview="${_preview_cmd}" \
    --preview-window='right:60%' \
    --header="${_header}")

  if [ -n "${_selected}" ]; then
    printf '%s\n' "${_selected}"
  fi

  unset _editor_cmd _open_cmd _clipboard_cmd _preview_cmd _header _files _selected
}

# Select git stashes
fzf_git_stash() {
  if ! command -v git > /dev/null; then
    echo "git is not installed" >&2
    return 1
  fi

  _clipboard_cmd="$(_fzf_get_clipboard)"

  _header="
  RETURN : Show   CTRL-X : Apply   CTRL-D : Drop
  CTRL-O : Copy Stash Name   CTRL-/: Toggle Preview   ESC : Exit"
  _header=$(echo "${_header}" | sed '1d')

  _stashes=$(git stash list)

  if [ -z "${_stashes}" ]; then
    echo "No stashes found" >&2
    unset _clipboard_cmd _header _stashes
    return 0
  fi

  _selected=$(printf '%s\n' "${_stashes}" | fzf \
    --bind="ctrl-x:execute-silent(git stash apply {1})+abort" \
    --bind="ctrl-d:execute-silent(git stash drop {1})+reload(git stash list)" \
    --bind="ctrl-o:execute-silent(printf '%s\n' {1} | ${_clipboard_cmd})" \
    --bind='ctrl-/:toggle-preview' \
    --preview="git stash show --stat --color=always {1}" \
    --preview-window='right:60%' \
    --header="${_header}")

  if [ -n "${_selected}" ]; then
    _stash_name=$(echo "${_selected}" | awk '{print $1}')
    git stash show -p "${_stash_name}"
    unset _stash_name
  fi

  unset _clipboard_cmd _header _stashes _selected
}

# ============================================================================
# Docker/Podman Integration
# ============================================================================

# Select docker/podman containers
fzf_docker_containers() {
  if command -v docker > /dev/null; then
    _docker_cmd="docker"
  elif command -v podman > /dev/null; then
    _docker_cmd="podman"
  else
    echo "docker or podman is not installed" >&2
    return 1
  fi

  _clipboard_cmd="$(_fzf_get_clipboard)"

  _header="
  RETURN : Inspect   CTRL-X : Stop   CTRL-S : Start   CTRL-R : Restart
  CTRL-D : Remove   CTRL-L : Logs   CTRL-O : Copy ID   ESC : Exit"
  _header=$(echo "${_header}" | sed '1d')

  _containers=$(${_docker_cmd} ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}")

  _selected=$(printf '%s\n' "${_containers}" | fzf \
    --header-lines=1 \
    --bind="ctrl-x:execute-silent(${_docker_cmd} stop {1})+reload(${_docker_cmd} ps -a --format 'table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}')" \
    --bind="ctrl-s:execute-silent(${_docker_cmd} start {1})+reload(${_docker_cmd} ps -a --format 'table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}')" \
    --bind="ctrl-r:execute-silent(${_docker_cmd} restart {1})+reload(${_docker_cmd} ps -a --format 'table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}')" \
    --bind="ctrl-d:execute-silent(${_docker_cmd} rm {1})+reload(${_docker_cmd} ps -a --format 'table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}')" \
    --bind="ctrl-l:execute(${_docker_cmd} logs -f {1})+abort" \
    --bind="ctrl-o:execute-silent(printf '%s\n' {1} | ${_clipboard_cmd})" \
    --preview="${_docker_cmd} inspect {1}" \
    --preview-window='right:60%' \
    --header="${_header}")

  if [ -n "${_selected}" ]; then
    _container_id=$(echo "${_selected}" | awk '{print $1}')
    ${_docker_cmd} inspect "${_container_id}"
    unset _container_id
  fi

  unset _docker_cmd _clipboard_cmd _header _containers _selected
}

# Select docker/podman images
fzf_docker_images() {
  if command -v docker > /dev/null; then
    _docker_cmd="docker"
  elif command -v podman > /dev/null; then
    _docker_cmd="podman"
  else
    echo "docker or podman is not installed" >&2
    return 1
  fi

  _clipboard_cmd="$(_fzf_get_clipboard)"

  _header="
  RETURN : Inspect   CTRL-X : Remove   CTRL-R : Run
  CTRL-O : Copy ID   CTRL-/: Toggle Preview   ESC : Exit"
  _header=$(echo "${_header}" | sed '1d')

  _images=$(${_docker_cmd} images --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}")

  _selected=$(printf '%s\n' "${_images}" | fzf \
    --header-lines=1 \
    --bind="ctrl-x:execute-silent(${_docker_cmd} rmi {1})+reload(${_docker_cmd} images --format 'table {{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}')" \
    --bind="ctrl-r:execute(${_docker_cmd} run -it {1} /bin/sh)+abort" \
    --bind="ctrl-o:execute-silent(printf '%s\n' {1} | ${_clipboard_cmd})" \
    --bind='ctrl-/:toggle-preview' \
    --preview="${_docker_cmd} inspect {1}" \
    --preview-window='right:60%' \
    --header="${_header}")

  if [ -n "${_selected}" ]; then
    _image_id=$(echo "${_selected}" | awk '{print $1}')
    ${_docker_cmd} inspect "${_image_id}"
    unset _image_id
  fi

  unset _docker_cmd _clipboard_cmd _header _images _selected
}

# ============================================================================
# Kubernetes Integration
# ============================================================================

# Select kubernetes pods
fzf_kube_pods() {
  if ! command -v kubectl > /dev/null; then
    echo "kubectl is not installed" >&2
    return 1
  fi

  _clipboard_cmd="$(_fzf_get_clipboard)"
  _editor_cmd="$(_fzf_get_editor)"

  _header="
  RETURN : Describe   CTRL-X : Delete   CTRL-L : Logs   CTRL-E : Exec
  CTRL-O : Copy Name   CTRL-/: Toggle Preview   ESC : Exit"
  _header=$(echo "${_header}" | sed '1d')

  _namespace="${1:-}"
  if [ -n "${_namespace}" ]; then
    _ns_flag="-n ${_namespace}"
    _ns_flag_space="${_ns_flag}"
  else
    _ns_flag=""
    _ns_flag_space=""
  fi

  _pods=$(eval "kubectl get pods ${_ns_flag} --no-headers 2>/dev/null" | awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5}')

  if [ -z "${_pods}" ]; then
    echo "No pods found" >&2
    unset _clipboard_cmd _editor_cmd _header _namespace _ns_flag _ns_flag_space _pods
    return 1
  fi

  # Build reload command
  if [ -n "${_ns_flag}" ]; then
    _reload_cmd="kubectl get pods ${_ns_flag} --no-headers | awk '{print \$1 \"\\t\" \$2 \"\\t\" \$3 \"\\t\" \$4 \"\\t\" \$5}'"
  else
    _reload_cmd="kubectl get pods --no-headers | awk '{print \$1 \"\\t\" \$2 \"\\t\" \$3 \"\\t\" \$4 \"\\t\" \$5}'"
  fi

  _selected=$(printf '%s\n' "${_pods}" | fzf \
    --bind="ctrl-x:execute-silent(kubectl delete pod {1} ${_ns_flag_space})+reload(${_reload_cmd})" \
    --bind="ctrl-l:execute(kubectl logs -f {1} ${_ns_flag_space})+abort" \
    --bind="ctrl-e:execute(kubectl exec -it {1} ${_ns_flag_space} -- /bin/sh)+abort" \
    --bind="ctrl-o:execute-silent(printf '%s\n' {1} | ${_clipboard_cmd})" \
    --bind='ctrl-/:toggle-preview' \
    --preview="kubectl describe pod {1} ${_ns_flag_space}" \
    --preview-window='right:60%' \
    --header="${_header}")

  if [ -n "${_selected}" ]; then
    _pod_name=$(echo "${_selected}" | awk '{print $1}')
    eval "kubectl describe pod \"${_pod_name}\" ${_ns_flag}"
    unset _pod_name
  fi

  unset _clipboard_cmd _editor_cmd _header _namespace _ns_flag _ns_flag_space _pods _reload_cmd _selected
}

# Select kubernetes contexts
fzf_kube_context() {
  if ! command -v kubectl > /dev/null; then
    echo "kubectl is not installed" >&2
    return 1
  fi

  _clipboard_cmd="$(_fzf_get_clipboard)"

  _header="
  RETURN : Switch Context   CTRL-O : Copy Name   ESC : Exit"
  _header=$(echo "${_header}" | sed '1d')

  _contexts=$(kubectl config get-contexts --no-headers -o name)

  _selected=$(printf '%s\n' "${_contexts}" | fzf \
    --bind="ctrl-o:execute-silent(printf '%s\n' {} | ${_clipboard_cmd})" \
    --preview="kubectl config view --context={} --minify" \
    --preview-window='right:60%' \
    --header="${_header}")

  if [ -n "${_selected}" ]; then
    kubectl config use-context "${_selected}"
  fi

  unset _clipboard_cmd _header _contexts _selected
}

# ============================================================================
# History & Commands
# ============================================================================

# Enhanced history search
fzf_history() {
  _clipboard_cmd="$(_fzf_get_clipboard)"

  _header="
  RETURN : Execute   CTRL-X : Edit   CTRL-O : Copy
  CTRL-/: Toggle Preview   ESC : Exit"
  _header=$(echo "${_header}" | sed '1d')

  # Preview command
  if command -v bat > /dev/null; then
    _preview_cmd="bat --plain --color=always --paging=never --style=grid --language=bash --line-range :500" 
  else
    _preview_cmd="cat"
  fi
  # Use HISTFILE if available, otherwise try shell-specific history
  # Try extended regex first (GNU/BSD), fallback to basic regex (POSIX)
  if sed -E '' /dev/null 2>/dev/null; then
    # Extended regex: match optional timestamp prefix and line numbers
    if [ -n "${HISTFILE:-}" ] && [ -r "${HISTFILE}" ]; then
      _hist_cmd="tail -n 1000 \"${HISTFILE}\" | sed -E 's/^(:[[:space:]]+[[:digit:]]+:[[:digit:]]+;)?[[:space:]]*[0-9]*[[:space:]]*//'"
    elif [ -n "${HISTFILE:-}" ]; then
      _hist_cmd="cat \"${HISTFILE}\" | sed -E 's/^(:[[:space:]]+[[:digit:]]+:[[:digit:]]+;)?[[:space:]]*[0-9]*[[:space:]]*//'"
    else
      _hist_cmd="history 2>/dev/null | sed -E 's/^(:[[:space:]]+[[:digit:]]+:[[:digit:]]+;)?[[:space:]]*[0-9]*[[:space:]]*//' || echo ''"
    fi
  else
    # POSIX basic regex: simpler pattern, just remove leading numbers and spaces
    if [ -n "${HISTFILE:-}" ] && [ -r "${HISTFILE}" ]; then
      _hist_cmd="tail -n 1000 \"${HISTFILE}\" | sed 's/^\(:[[:space:]]\+[[:digit:]]\+:[[:digit:]]\+;\)\?[[:space:]]*[0-9]*[[:space:]]*//'"
    elif [ -n "${HISTFILE:-}" ]; then
      _hist_cmd="cat \"${HISTFILE}\" | sed 's/^\(:[[:space:]]\+[[:digit:]]\+:[[:digit:]]\+;\)\?[[:space:]]*[0-9]*[[:space:]]*//'"
    else
      _hist_cmd="history 2>/dev/null | sed 's/^\(:[[:space:]]\+[[:digit:]]\+:[[:digit:]]\+;\)\?[[:space:]]*[0-9]*[[:space:]]*//' || echo ''"
    fi
  fi
  _selected=$(eval "${_hist_cmd}" | awk '!seen[$0]++' | fzf \
    --bind="ctrl-x:execute($(_fzf_get_editor) <(echo {}))+abort" \
    --bind="ctrl-o:execute-silent(printf '%s\n' {} | ${_clipboard_cmd})" \
    --bind='ctrl-/:toggle-preview' \
    --preview="printf '%s' {} | ${_preview_cmd}"\
    --preview-window='down:3' \
    --header="${_header}")

  if [ -n "${_selected}" ]; then
    # Print to stdout - caller can handle execution
    printf '%s\n' "${_selected}"
  fi

  unset _clipboard_cmd _header _preview_cmd _hist_cmd _selected
}

# ============================================================================
# SSH & Network
# ============================================================================

# Select SSH hosts from config
fzf_ssh() {
  if [ ! -f "${HOME}/.ssh/config" ]; then
    echo "SSH config not found at ${HOME}/.ssh/config" >&2
    return 1
  fi

  _clipboard_cmd="$(_fzf_get_clipboard)"

  _header="
  RETURN : Connect   CTRL-O : Copy Host   ESC : Exit"
  _header=$(echo "${_header}" | sed '1d')

  _hosts=$(grep -E "^Host " "${HOME}/.ssh/config" | awk '{print $2}' | grep -v '^\*$')

  if [ -z "${_hosts}" ]; then
    echo "No SSH hosts found in config" >&2
    unset _clipboard_cmd _header _hosts
    return 1
  fi

  _selected=$(printf '%s\n' "${_hosts}" | fzf \
    --bind="ctrl-o:execute-silent(printf '%s\n' {} | ${_clipboard_cmd})" \
    --preview="grep -A 10 '^Host {}' ${HOME}/.ssh/config" \
    --preview-window='right:50%' \
    --header="${_header}")

  if [ -n "${_selected}" ]; then
    ssh "${_selected}"
  fi

  unset _clipboard_cmd _header _hosts _selected
}

# ============================================================================
# Environment Variables
# ============================================================================

# Browse environment variables
fzf_env() {
  _clipboard_cmd="$(_fzf_get_clipboard)"
  _editor_cmd="$(_fzf_get_editor)"

  _header="
  RETURN : Show Value   CTRL-O : Copy   ALT-X : Edit
  CTRL-/: Toggle Preview   ESC : Exit"
  _header=$(echo "${_header}" | sed '1d')

  if command -v bat > /dev/null; then
    _preview_cmd="bat --plain --color=always --paging=never --style=grid --language=bash --line-range :500" 
  else
    _preview_cmd="cat"
  fi

  _env_vars=$(env | sort)

  _selected=$(printf '%s\n' "${_env_vars}" | fzf \
    --delimiter '=' \
    --with-nth '{1}={2}' \
    --accept-nth '{2}' \
    --bind="ctrl-o:execute-silent(printf '%s\n' {2} | ${_clipboard_cmd})" \
    --bind="alt-x:execute(${_editor_cmd} <(printf '%s=%s\n' {1} {2}))+abort" \
    --bind='ctrl-/:toggle-preview' \
    --preview="printf '%s=%s\n' {1} {2} | ${_preview_cmd}" \
    --preview-window='down:3' \
    --header="${_header}")

  if [ -n "${_selected}" ]; then
    echo "${_selected#*=}"
  fi

  unset _clipboard_cmd _editor_cmd _header _env_vars _selected
}

# ============================================================================
# File Operations
# ============================================================================

# Copy files with fzf
fzf_cp() {
  _search_path="${1:-.}"
  _dst="${2:-}"

  if command -v fd > /dev/null; then
    _find_cmd="fd --hidden --follow --type f -- \"${_search_path}\""
  else
    _find_cmd="find \"${_search_path}\" -type f"
  fi

  _selected=$(eval "${_find_cmd}" | fzf --multi)

  if [ -z "${_selected}" ]; then
    unset _search_path _dst _find_cmd _selected
    return 0
  fi

  if [ -z "${_dst}" ]; then
    printf 'Destination directory: '
    read -r _dst
  fi

  if [ -n "${_dst}" ] && [ -d "${_dst}" ]; then
    printf '%s\n' "${_selected}" | while IFS= read -r _file; do
    if [ -n "${_file}" ]; then
      cp -- "${_file}" "${_dst}/"
    fi
  done
  _count=$(printf '%s\n' "${_selected}" | wc -l | tr -d ' ')
  echo "Copied ${_count} file(s) to ${_dst}"
  unset _count
else
  echo "Invalid destination: ${_dst}" >&2
  unset _search_path _dst _find_cmd _selected
  return 1
  fi

  unset _search_path _dst _find_cmd _selected
}

# Move files with fzf
fzf_mv() {
  _search_path="${1:-.}"
  _dst="${2:-}"

  if command -v fd > /dev/null; then
    _find_cmd="fd --hidden --follow --type f -- \"${_search_path}\""
  else
    _find_cmd="find \"${_search_path}\" -type f"
  fi

  _selected=$(eval "${_find_cmd}" | fzf --multi)

  if [ -z "${_selected}" ]; then
    unset _search_path _dst _find_cmd _selected
    return 0
  fi

  if [ -z "${_dst}" ]; then
    printf 'Destination directory: '
    read -r _dst
  fi

  if [ -n "${_dst}" ] && [ -d "${_dst}" ]; then
    printf '%s\n' "${_selected}" | while IFS= read -r _file; do
    if [ -n "${_file}" ]; then
      mv -- "${_file}" "${_dst}/"
    fi
  done
  _count=$(printf '%s\n' "${_selected}" | wc -l | tr -d ' ')
  echo "Moved ${_count} file(s) to ${_dst}"
  unset _count
else
  echo "Invalid destination: ${_dst}" >&2
  unset _search_path _dst _find_cmd _selected
  return 1
  fi

  unset _search_path _dst _find_cmd _selected
}

# Delete files with fzf (with confirmation)
fzf_rm() {
  _search_path="${1:-.}"
  if command -v fd > /dev/null; then
    _find_cmd="fd --hidden --follow --type f -- \"${_search_path}\""
  else
    _find_cmd="find \"${_search_path}\" -type f"
  fi

  _selected=$(eval "${_find_cmd}" | fzf --multi \
    --bind="ctrl-x:execute-silent(rm {+})+reload(${_find_cmd})" \
    --header="CTRL-X : Delete Selected   ESC : Exit")

  if [ -n "${_selected}" ]; then
    echo "Selected files:"
    echo "${_selected}"
    printf 'Delete these files? [y/N]: '
    read -r _confirm
    if [ "${_confirm}" = "y" ] || [ "${_confirm}" = "Y" ]; then
      printf '%s\n' "${_selected}" | while IFS= read -r _file; do
      if [ -n "${_file}" ]; then
        rm -- "${_file}"
      fi
    done
    _count=$(printf '%s\n' "${_selected}" | wc -l | tr -d ' ')
    echo "Deleted ${_count} file(s)"
    unset _count
    fi
    unset _confirm
  fi

  unset _search_path _find_cmd _selected
}

# ============================================================================
# Z Directory Integration
# ============================================================================

# Jump to directory using z (frecency)
fzf_z() {
  if ! command -v z > /dev/null; then
    echo "z (frecency directory jumper) is not installed" >&2
    return 1
  fi

  _clipboard_cmd="$(_fzf_get_clipboard)"
  _preview_cmd="$(_fzf_get_dir_preview)"

  _header="
  RETURN : cd   CTRL-O : Copy Path   CTRL-/: Toggle Preview   ESC : Exit"
  _header=$(echo "${_header}" | sed '1d')

  _dirs=$(z -l 2>/dev/null | awk '{print $2}' | sort -u)

  _selected=$(printf '%s\n' "${_dirs}" | fzf \
    --bind="ctrl-o:execute-silent(printf '%s\n' {} | ${_clipboard_cmd})" \
    --bind='ctrl-/:toggle-preview' \
    --preview="${_preview_cmd}" \
    --preview-window='right:60%' \
    --header="${_header}")

  if [ -n "${_selected}" ]; then
    cd "${_selected}" || return 1
  fi

  unset _clipboard_cmd _preview_cmd _header _dirs _selected
}

# ============================================================================
# Man Pages
# ============================================================================

# Browse man pages
fzf_man() {
  _clipboard_cmd="$(_fzf_get_clipboard)"
  _editor_cmd="$(_fzf_get_editor)"

  _header="
  RETURN : View   CTRL-O : Copy   ALT-X : View in Editor   ESC : Exit"
  _header=$(echo "${_header}" | sed '1d')

  # Man pager command
  if command -v bat > /dev/null; then
    _manpager_cmd="bat --language=Manpage --plain --color=always --style=grid"
  elif command -v less > /dev/null; then
    _manpager_cmd="less --RAW-CONTROL-CHARS --quit-if-one-screen --mouse --ignore-case --SILENT -X"
  else
    _manpager_cmd="${MANPAGER:-cat}"
  fi

  # Parse man pages: extract name and section
  # Format: "name(section) - description" or "name(section), other"
  # Try extended regex first (GNU/BSD), fallback to basic regex (POSIX)
  if sed -nE '' /dev/null 2>/dev/null; then
    _man_pages=$(man -k . 2>/dev/null | sed -nE 's:^[[:space:]]*([^[:space:](]+)\(([[:digit:]]+)\).*:\1,\2:p' | sort -u)
  else
    # POSIX basic regex fallback
    _man_pages=$(man -k . 2>/dev/null | sed -n 's:^[[:space:]]*\([^[:space:](]*\)(\([[:digit:]]*\)).*:\1,\2:p' | sort -u)
  fi

  if [ -z "${_man_pages}" ]; then
    echo "No man pages found" >&2
    unset _clipboard_cmd _editor_cmd _header _man_pages
    return 1
  fi

  _selected=$(printf '%s\n' "${_man_pages}" | MANPAGER="${_manpager_cmd}" fzf \
    --delimiter ',' \
    --with-nth '{1}' \
    --accept-nth '{1}' \
    --bind="ctrl-o:execute-silent(printf '%s\n' {1} | ${_clipboard_cmd})" \
    --bind="alt-x:execute(man {2} {1} | ${_editor_cmd} -)+abort" \
    --preview="man {2} {1} 2> /dev/null" \
    --preview-window='right:60%' \
    --header="${_header}")

  if [ -n "${_selected}" ]; then
    _man_name=$(echo "${_selected}" | cut -d',' -f1)
    _man_section=$(echo "${_selected}" | cut -d',' -f2)
    man "${_man_section}" "${_man_name}" 2>/dev/null || man "${_man_name}"
    unset _man_name _man_section
  fi

  unset _clipboard_cmd _editor_cmd _header _man_pages _selected
}

# ============================================================================
# System Services (systemd)
# ============================================================================

# Select systemd services
fzf_systemd() {
  if ! command -v systemctl > /dev/null; then
    echo "systemctl is not available" >&2
    return 1
  fi

  _clipboard_cmd="$(_fzf_get_clipboard)"

  _header="
  RETURN : Status   CTRL-X : Stop   CTRL-S : Start   CTRL-R : Restart
  CTRL-E : Enable   CTRL-D : Disable   CTRL-L : Logs   CTRL-O : Copy Name   ESC : Exit"
  _header=$(echo "${_header}" | sed '1d')

  _services=$(systemctl list-units --type=service --no-pager --no-legend 2>/dev/null | awk '{print $1}')

  if [ -z "${_services}" ]; then
    echo "No services found" >&2
    unset _clipboard_cmd _header _services
    return 1
  fi

  _selected=$(printf '%s\n' "${_services}" | fzf \
    --bind="ctrl-x:execute-silent(sudo systemctl stop {})+reload(systemctl list-units --type=service --no-pager --no-legend | awk '{print \$1}')" \
    --bind="ctrl-s:execute-silent(sudo systemctl start {})+reload(systemctl list-units --type=service --no-pager --no-legend | awk '{print \$1}')" \
    --bind="ctrl-r:execute-silent(sudo systemctl restart {})+reload(systemctl list-units --type=service --no-pager --no-legend | awk '{print \$1}')" \
    --bind="ctrl-e:execute-silent(sudo systemctl enable {})+reload(systemctl list-units --type=service --no-pager --no-legend | awk '{print \$1}')" \
    --bind="ctrl-d:execute-silent(sudo systemctl disable {})+reload(systemctl list-units --type=service --no-pager --no-legend | awk '{print \$1}')" \
    --bind="ctrl-l:execute(sudo journalctl -u {} -f)+abort" \
    --bind="ctrl-o:execute-silent(printf '%s\n' {} | ${_clipboard_cmd})" \
    --preview="systemctl status {}" \
    --preview-window='right:60%' \
    --header="${_header}")

  if [ -n "${_selected}" ]; then
    systemctl status "${_selected}"
  fi

  unset _clipboard_cmd _header _services _selected
}

# ============================================================================
# Web Resources
# ============================================================================

# Download
fzf_dlp() {
  if test "$#" -eq 0
  then
    printf "Usage: fzdlp URL_SOURCE ...\n" >&2
    return 2
  fi
  fzf \
    --multi \
    --bind=start,change:"reload(cat -- $*)" \
    --bind=ctrl-m:'execute-silent(printf %s\\0 {+} | xargs -0 -n 1 firefox --private-window &)' \
    --bind=ctrl-x:'execute-silent(alacritty -e tmux new-session -A -s "fzf-dlp-$$" -- yt-dlp --quiet --progress -f "bv*+ba/b" -N 128 -- {+} &)'
}

# ============================================================================
# Export all aliases
# ============================================================================

alias fzkill='fzf_kill'
alias fzgrep='fzf_grep'
alias fzfiles='fzf_files'
alias fzdirs='fzf_dirs'
alias fzgb='fzf_git_branch'
alias fzgc='fzf_git_commit'
alias fzgf='fzf_git_files'
alias fzgs='fzf_git_stash'
alias fzdocker='fzf_docker_containers'
alias fzdimg='fzf_docker_images'
alias fzkp='fzf_kube_pods'
alias fzkc='fzf_kube_context'
alias fzh='fzf_history'
alias fzssh='fzf_ssh'
alias fzenv='fzf_env'
alias fzcp='fzf_cp'
alias fzmv='fzf_mv'
alias fzrm='fzf_rm'
alias fzz='fzf_z'
alias fzman='fzf_man'
alias fzsd='fzf_systemd'
alias fzdlp='fzf_dlp'

# List all available fzf extensions
fzf_extensions_help() {
  cat << 'EOF'
  Available fzf extensions:

  Process Management:
  fzkill, fzf_kill          - Kill processes interactively

  File Operations:
  fzfiles, fzf_files        - Find files with preview
  fzdirs, fzf_dirs          - Find directories with preview
  fzgrep, fzf_grep          - Search file contents with ripgrep
  fzcp, fzf_cp              - Copy files interactively
  fzmv, fzf_mv              - Move files interactively
  fzrm, fzf_rm              - Delete files interactively

  Git Integration:
  fzgb, fzf_git_branch      - Select and checkout git branches
  fzgc, fzf_git_commit      - Browse git commits
  fzgf, fzf_git_files       - Select git-tracked files
  fzgs, fzf_git_stash       - Browse git stashes

  Docker/Podman:
  fzdocker, fzf_docker_containers - Manage containers
  fzdimg, fzf_docker_images       - Manage images

  Kubernetes:
  fzkp, fzf_kube_pods       - Select kubernetes pods
  fzkc, fzf_kube_context    - Switch kubernetes contexts

  History & Commands:
  fzh, fzf_history          - Enhanced history search

  SSH & Network:
  fzssh, fzf_ssh            - Select SSH hosts from config

  Environment:
  fzenv, fzf_env            - Browse environment variables

  Directory Navigation:
  fzz, fzf_z                - Jump to directories using z

  Web Download:
  fzdlp                     - Download media using yt-dlp

  System:
  fzman, fzf_man            - Browse man pages
  fzsd, fzf_systemd         - Manage systemd services

  Help:
  fzf_extensions_help       - Show this help message
EOF
}

alias fzf-extensions-help="fzf_extensions_help"


# vi:et:ft=sh:sts=2:sw=2:ts=2:tw=0
