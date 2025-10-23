#!/usr/bin/env sh
# ~/.profile.d/fzf.sh: look for an fzf installation and append it to the PATH
# This script also has functions that extend the functionality of fzf

if test -n "${FZF_BASE+X}"
then
  export FZF_BASE
elif test -d "${XDG_DATA_HOME:-${HOME}/.local/share}/fzf"
then
  export FZF_BASE="${XDG_DATA_HOME:-${HOME}/.local/share}/fzf"
elif test -d '/usr/local/share/fzf'
then
  export FZF_BASE='/usr/local/share/fzf'
elif test -d '/usr/share/fzf'
then
  export FZF_BASE='/usr/share/fzf'
elif test -d '/opt/fzf'
then
  export FZF_BASE='/opt/fzf'
else
  unset FZF_BASE
fi

# Kill processes
fzf_kill() (
  usage='fzf_kill [-s SIG_NAME] [INITIAL_SEARCH]'
  ps_cmd="ps ax"
  ps_format="user=UID,pid,ppid,c,stat,stime,tname,time,cmd"
  kill_prefix="kill"
  kill_signal="TERM"

  if command -v pstree > /dev/null; then
    preview_cmd='pstree --ascii --arguments --show-pids --uid-changes --hide-threads --color=age --highlight-pid {2}'
  else
    preview_cmd='ps -p {+2}'
  fi

  while getopts ':hs:' opt; do
    case "${opt}" in
      h)
        printf 'usage: %s\n' "${usage}"
        return 0
        ;;
      s)
        kill_signal="${OPTARG}"
        ;;
      '?')
        echo "fzf_kill: -${OPTARG}: invalid option" >&2
        printf 'usage: %s\n' "${usage}" >&2
        return 2
        ;;
      ':')
        echo "fzf_kill: -${OPTARG}: missing required argument" >&2
        printf 'usage: %s\n' "${usage}" >&2
        return 2
        ;;
    esac
  done
  shift "$((OPTIND - 1))"
  if test "$#" -gt 1; then
    echo "fzf_kill: too many arguments" >&2
    printf 'usage: %s\n' "${usage}" >&2
    return 2
  fi
  kill_prefix="${kill_prefix} -s ${kill_signal}"

  header="
Ctrl-R : Reload List    Tab   : Select + ↓  Shift-Tab : Select + ↑
Ctrl-X : Kill Selected  Enter : Print PIDs  Esc : Cancel"

  # shellcheck disable=SC2046
  FZF_DEFAULT_COMMAND="${ps_cmd}" PS_FORMAT="${ps_format}" fzf \
    --multi \
    --accept-nth=2 \
    --header-lines=1 \
    --bind="tab:toggle+down" \
    --bind="shift-tab:toggle+up" \
    --bind="enter:accept" \
    --bind="ctrl-r:clear-query+clear-multi+reload(${ps_cmd})+transform-ghost:date '+* updated %r'" \
    --bind="ctrl-x:become(sh -x -c '\"\$@\"' -- ${kill_prefix} {+2} >&2)+clear-multi+abort" \
    --bind='esc:abort' \
    --preview-window="down,28%,nowrap" \
    --preview="${preview_cmd}" \
    --layout=reverse \
    --header="${header#?}" \
    --query "$1"
)
alias fzf-kill='fzf_kill'


# Find files by content
fzf_grep() (
  if test "$#" -gt 1; then
    echo "usage: fzf_grep [PATH]" >&2
    return 2
  fi

  rg_cmd="rg --no-column --hidden --no-line-number"

  open_cmd=""
  case "$(uname)" in
    "Darwin") open_cmd=open ;;
    *) open_cmd=xdg-open ;;
  esac

  preview_cmd=""
  if command -v bat >/dev/null; then
    preview_cmd="bat --color=always --paging=never --style=numbers --line-range :500 -- {}"
  else
    preview_cmd="cat -- {}"
  fi

  # shellcheck disable=SC2046
  FZF_GREP_SEARCH_PATH="$1" FZF_DEFAULT_COMMAND="${rg_cmd} --color=never --files-with-matches -- '.*' \"\${FZF_GREP_SEARCH_PATH:-.}\"" fzf \
    --disabled \
    --bind="change:reload:${rg_cmd} --color=never --files-with-matches -- {q} \"\${FZF_GREP_SEARCH_PATH:-.}\" || true" \
    --bind='ctrl-j:replace-query+print-query' \
    --bind='ctrl-k:kill-line' \
    --bind='ctrl-c:abort' \
    --bind="ctrl-x:execute-silent(${open_cmd} {})+abort" \
    --bind="alt-x:execute(${EDITOR:-editor} {})" \
    --preview-window='top:60%' \
    --layout='reverse-list' \
    --preview="${preview_cmd} | ${rg_cmd} --colors 'match:bg:yellow' --passthru -- {q} || ${rg_cmd} -- {q} {}"
)
alias fzf-grep='fzf_grep'
