#!/usr/bin/env sh
# fzf-extensions.sh
# This script has functions that extend the functionality of fzf


# Kill processes
fzf_kill() (
  usage='fzf_kill [-s SIG_NAME] SEARCH'
  ps_cmd="ps -e -o user,pid,ppid,stat,stime,tt,time,command=CMD"
  kill_prefix="kill"
  kill_signal="TERM"

  if command -v strace > /dev/null; then
    preview_cmd='strace -p {2}'
  elif command -v top > /dev/null; then
    preview_cmd='top -pid {2}'
  elif command -v htop > /dev/null; then
    preview_cmd='htop -p {2}'
  else
    preview_cmd='ps -E -o command -p {2}'
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
CTRL-R : Reload PID Listing   TAB : Select-Toggle + ↓   SHIFT-TAB: Select-Toggle + ↑
CTRL-X : Kill Selected PIDs   RETURN : Print Selected   ESC : Clear Selection + Exit"
  header="${header#?}"

  # shellcheck disable=SC2046
  eval "${ps_cmd}" | fzf \
    --multi \
    --accept-nth=2 \
    --header-lines=2 \
    --bind="tab:toggle+down" \
    --bind="shift-tab:toggle+up" \
    --bind='enter:accept' \
    --bind="ctrl-r:clear-query+clear-multi+reload(${ps_cmd})+transform-ghost:date '+%* updated %r'" \
    --bind="ctrl-x:execute(${kill_prefix} {+2})+clear-multi+print(* Sent ${kill_signal})+accept" \
    --bind='esc:abort' \
    --preview="${preview_cmd}" \
    --preview-window='down,25%,follow,nowrap,noinfo' \
    --layout=reverse \
    --header="${header}" \
    --query "$1"
)
alias fzkill='fzf_kill'


# Find files by content
fzf_grep() (
  if ! command -v rg > /dev/null; then
    echo "ripgrep is not installed" >&2
    return 1
  fi

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
    preview_cmd="bat --color=always --paging=never --style=numbers --line-range :1000 -- {}"
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
alias fzrg
