#!/usr/bin/env sh
# install-dotfiles.sh
#
# For each file and directory tracked at the top level of this repository,
# create a symbolic link in the invoking user's home directory. The name
# of the link will match the name of the file it links to, prefixed with
# a period ('.').

set -eu

argzero_name="${0##*/}"
argzero_dirname="${0%"${argzero_name}"}"
argzero_dirname="${argzero_dirname:-.}"

usage="${argzero_name} [-n|-i|-f] [--] [TARGET_DIRECTORY]"

print_help() {
  cat
} <<EOF
usage: ${usage}

${argzero_name} - link dotfiles into a user's home directory

For each file and directory tracked at the top level of this repository,
create a symbolic link in the invoking user's home directory. The name
of the link will match the name of the file it links to, prefixed with
a period ('.').

The options "-n", "-i", and "-f", control whether or not existing files
are replaced. With "-n", no files are replaced. With "-i", the user is
prompted interactively for any file that would be replaced. With "-f",
the user is not prompted and files are replaced.
EOF

ln_opts="snv" # -s symlink, -n no-dereference, -v verbose

if test -t 0; then
  ln_replace='i'
else
  ln_replace=''
fi

dry_run='' # -n: don't activate services (preview-only)

OPTIND=1
option=''
optstr=':hnif'

while getopts "${optstr}" option; do
  case "${option}" in
  'h')
    print_help
    exit 0
    ;;
  '?')
    printf '%s: -%c: unrecognized option\n' "${argzero_name}" "${OPTARG}" >&2
    printf 'usage: %s\n' "${usage}" >&2
    exit 2
    ;;
  ':')
    printf '%s: -%c: missing required argument\n' "${argzero_name}" "${OPTARG}" >&2
    printf 'usage: %s\n' "${usage}" >&2
    exit 2
    ;;
  'n')
    ln_replace=''
    dry_run='1'
    ;;
  'i') ln_replace='i' ;;
  'f') ln_replace='f' ;;
  esac
done
shift "$((OPTIND - 1))"

ln_opts="${ln_opts}${ln_replace}"

# xargs -o (reopen /dev/tty in the child) is only needed so `ln -i` can prompt.
# Passing it unconditionally makes the installer abort with no controlling tty
# (CI, provisioning, `ssh host 'sh install-dotfiles.sh -f'`), so gate it on the
# interactive path.
if test "${ln_replace}" = 'i'; then
  xargs_tty='-o'
else
  xargs_tty=''
fi

if test "$#" -gt 1; then
  printf '%s: received too many arguments\n' "${argzero_name}" >&2
  printf 'usage: %s\n' "${usage}" >&2
  exit 2
fi

if test "$#" -eq 0; then
  home_path="$(cd 2>/dev/null && pwd -P && echo '@')"
  home_path="${home_path%?@}"
else
  home_path="$(cd -- "$1" >/dev/null && pwd -P && echo '@')" # suppress CDPATH noise
  home_path="${home_path%?@}"
  shift
fi

tree_path="$(cd -- "${argzero_dirname}" >/dev/null && pwd -P && echo '@')" # suppress CDPATH noise
tree_path="${tree_path%?@}"
repo_path="${tree_path}"

# Fail loudly on a non-repo rather than silently linking nothing (this is what
# `set -o pipefail` used to catch on the git|xargs pipelines below).
git -C "${repo_path}" rev-parse --git-dir >/dev/null 2>&1 || {
  printf '%s: %s is not a git repository\n' "${argzero_name}" "${repo_path}" >&2
  exit 1
}

# relpath TARGET BASE — print TARGET relative to BASE (both absolute), computed
# lexically: walk BASE up to the common ancestor emitting '../' per level, then
# append the rest of TARGET. Used for every symlink below, so each is relative
# (portable across a home-directory rename) and minimal at any depth.
relpath() {
  _rp_target=$1
  _rp_base=$2
  _rp_up=''
  while
    case "${_rp_target}" in
    "${_rp_base}") false ;;     # equal: common ancestor reached
    "${_rp_base%/}"/*) false ;; # %/ so a root base ('/') yields '/*', not '//*'
    *) true ;;
    esac
  do
    _rp_base=${_rp_base%/*}
    _rp_up="../${_rp_up}"
    test -n "${_rp_base}" || {
      _rp_base='/'
      break
    }
  done
  _rp_rest=${_rp_target#"${_rp_base}"}
  _rp_out="${_rp_up}${_rp_rest#/}"
  _rp_out=${_rp_out%/}          # drop trailing slash from a pure-ascent result
  printf '%s\n' "${_rp_out:-.}" # equal paths -> '.'
}

# Home dotfile links sit directly in $home, so each targets the repo relative
# to home.
tree_path="$(relpath "${repo_path}" "${home_path}")"

# shellcheck disable=SC2016
git -C "${repo_path}" ls-tree --name-only -z HEAD | xargs -0 -n 1 ${xargs_tty} -- sh -c '
caller=$1
dry_run=$2
optchars=$3
treepath=$4
destpath=$5
filename=$6
# skip: this script, dotfiles already prefixed with '.', markdown files, and
# XDG-specific directories that have canonical locations outside ~/.*
case "${filename}" in
  "${caller}"|.*|*.md|environment.d|launchd|scripts|systemd|user-tmpfiles.d)
    exit 0
    ;;
esac
src="${treepath:+${treepath}/}${filename}"
dst="${destpath:+${destpath}/}.${filename}"
if test -n "${dry_run}"; then
  if test -e "${dst}" || test -L "${dst}"; then
    printf "skip (exists): %s\n" "${dst}"
  else
    printf "would link: %s -> %s\n" "${dst}" "${src}"
  fi
else
  ln "-${optchars}" -- "${src}" "${dst}" \
    || case "${optchars}" in *f*) exit 1 ;; esac
fi
' -- "${argzero_name}" "${dry_run}" "${ln_opts}" "${tree_path}" "${home_path}"

# Link tracked helper scripts into ~/.local/bin so they are on PATH (the
# launchd/systemd units reference them there). New scripts dropped in scripts/
# become available on the next install with no further wiring.
local_bin="${home_path}/.local/bin"
test -n "${dry_run}" || mkdir -p -- "${local_bin}"
# shellcheck disable=SC2016
git -C "${repo_path}" ls-tree --name-only -z HEAD:scripts |
  xargs -0 -n 1 ${xargs_tty} -- sh -c '
dry_run=$1
optchars=$2
src_dir=$3
dst_dir=$4
filename=$5
if test -n "${dry_run}"; then
  printf "would link: %s/%s -> %s/%s\n" "${dst_dir}" "${filename}" "${src_dir}" "${filename}"
else
  ln "-${optchars}" -- "${src_dir}/${filename}" "${dst_dir}/${filename}" || :
fi
' -- "${dry_run}" "${ln_opts}" "$(relpath "${repo_path}/scripts" "${local_bin}")" "${local_bin}" || :

# On macOS, generate launchd agent plists into ~/Library/LaunchAgents. launchd
# requires absolute paths, so the tracked plists carry a __HOME__ placeholder
# that is substituted for the real home here -- a symlink would leave __HOME__
# unresolved. This also survives a future username change (re-run the install).
case "$(uname -s)" in Darwin)
  launch_agents="${home_path}/Library/LaunchAgents"
  test -n "${dry_run}" || mkdir -p -- "${launch_agents}"
  # shellcheck disable=SC2016
  git -C "${repo_path}" ls-tree --name-only -z HEAD:launchd/agents |
    xargs -0 -n 1 ${xargs_tty} -- sh -c '
dry_run=$1
optchars=$2
src_dir=$3
dst_dir=$4
home=$5
filename=$6
src="${src_dir}/${filename}"
dst="${dst_dir}/${filename}"
if test -n "${dry_run}"; then
  printf "would generate: %s (from %s, __HOME__ -> %s)\n" "${dst}" "${filename}" "${home}"
  exit 0
fi
if test -e "${dst}"; then
  case "${optchars}" in
  *f*) : ;;                                     # force: overwrite
  *i*)
    printf "%s exists. Overwrite? [y/N] " "${dst}" > /dev/tty
    read -r reply < /dev/tty || reply=""
    case "${reply}" in [Yy]*) : ;; *) exit 0 ;; esac
    ;;
  *) exit 0 ;;                                  # no-clobber: leave it in place
  esac
fi
sed "s|__HOME__|${home}|g" -- "${src}" > "${dst}"
' -- "${dry_run}" "${ln_opts}" "${repo_path}/launchd/agents" "${launch_agents}" "${home_path}" || :

  # Load the lightweight agents now instead of at next login. Needs a GUI
  # session (gui/$UID), so probe that domain and skip over SSH. mcphub is
  # heavyweight and stays manual (see CLAUDE.md).
  launch_domain="gui/$(id -u)"
  if test -z "${dry_run}" && launchctl print "${launch_domain}" > /dev/null 2>&1; then
    for plist in "${launch_agents}"/com.patrickdeyoreo.*.plist; do
      test -e "${plist}" || continue
      label="${plist##*/}"
      label="${label%.plist}"
      case "${label}" in *mcphub*) continue ;; esac
      # bootstrap loads it; if already loaded, kickstart -k restarts it.
      launchctl bootstrap "${launch_domain}" "${plist}" 2> /dev/null ||
        launchctl kickstart -k "${launch_domain}/${label}" 2> /dev/null || :
    done
  fi
  ;;
esac

# On Linux, enable the user services we ship. They already live under
# ~/.config/systemd/user (this repo is $XDG_CONFIG_HOME), so there's nothing to
# link — just register them. Skip templated units (they need an instance), and
# stay best-effort: no systemd user session must not fail the install.
case "$(uname -s)" in Linux)
  if command -v systemctl > /dev/null 2>&1; then
    systemctl --user daemon-reload 2> /dev/null || :
    # Starting units needs a reachable user bus; else just register for login.
    if test -z "${dry_run}" && systemctl --user list-units > /dev/null 2>&1; then
      have_session=1
    else
      have_session=''
    fi
    for unit in "${repo_path}"/systemd/user/*.service "${repo_path}"/systemd/user/*.socket; do
      test -e "${unit}" || continue
      unit_name="${unit##*/}"
      case "${unit_name}" in *@.*) continue ;; esac # templated: needs an instance
      systemctl --user enable "${unit_name}" 2> /dev/null || :
      case "${unit_name}" in mcphub.*) continue ;; esac # heavyweight: stays manual
      if test -n "${have_session}"; then
        systemctl --user enable --now "${unit_name}" 2> /dev/null || :
        systemctl --user try-restart "${unit_name}" 2> /dev/null || : # pick up edits
      fi
    done
  fi
  ;;
esac

exit
