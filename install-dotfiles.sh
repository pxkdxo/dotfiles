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

usage="${argzero_name} [-n] [--] [TARGET_DIRECTORY]"

print_help() {
  cat
} << EOF
usage: ${usage}

${argzero_name} - link dotfiles into a user's home directory

For each file and directory tracked at the top level of this repository,
create a symbolic link in the invoking user's home directory. The name
of the link will match the name of the file it links to, prefixed with
a period ('.').

The installer is idempotent and non-interactive: every run overwrites its own
links so the tree converges regardless of prior state. Whatever is already at a
link's location -- a real file, a foreign symlink, or a real directory -- is
replaced (a directory is removed first, since a symlink cannot replace one in
place). "-n" previews all actions, flagging any directory that would be removed,
without touching anything.
EOF

dry_run='' # -n: preview only; don't touch the filesystem or activate services

OPTIND=1
option=''
while getopts ':hn' option; do
  case "${option}" in
    'h')
      print_help
      exit 0
      ;;
    'n') dry_run='1' ;;
    '?')
      printf '%s: -%c: unrecognized option\n' "${argzero_name}" "${OPTARG}" >&2
      printf 'usage: %s\n' "${usage}" >&2
      exit 2
      ;;
  esac
done
shift "$((OPTIND - 1))"

if test "$#" -gt 1; then
  printf '%s: received too many arguments\n' "${argzero_name}" >&2
  printf 'usage: %s\n' "${usage}" >&2
  exit 2
fi

if test "$#" -eq 0; then
  home_path="$(cd 2> /dev/null && pwd -P && echo '@')"
  home_path="${home_path%?@}"
else
  home_path="$(cd -- "$1" > /dev/null && pwd -P && echo '@')" # suppress CDPATH noise
  home_path="${home_path%?@}"
  shift
fi

tree_path="$(cd -- "${argzero_dirname}" > /dev/null && pwd -P && echo '@')" # suppress CDPATH noise
tree_path="${tree_path%?@}"
repo_path="${tree_path}"

# Fail loudly on a non-repo rather than silently linking nothing.
git -C "${repo_path}" rev-parse --git-dir > /dev/null 2>&1 || {
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
      "${_rp_base}") false ;;   # equal: common ancestor reached
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

# Shared link helper (used by the blocks below via `sh -c`). ln -sfn is
# idempotent: it recreates the link over any file or symlink (-n/-h replaces a
# symlink-to-dir instead of dereferencing into it). The one case it can't handle
# is a real directory -- ln would nest a link inside it -- so remove that first.
# shellcheck disable=SC2016 # this is a `sh -c` body; it must not expand here
link_body='
dst_link() {
  src=$1
  dst=$2
  if test -d "${dst}" && ! test -L "${dst}"; then
    if test -n "${DRY_RUN}"; then
      printf "link: %s -> %s (replaces existing directory)\n" "${dst}" "${src}"
      return
    fi
    rm -rf -- "${dst}"
  elif test -n "${DRY_RUN}"; then
    printf "link: %s -> %s\n" "${dst}" "${src}"
    return
  fi
  ln -sfnv -- "${src}" "${dst}"
}
'

# Home dotfile links sit directly in $home, so each targets the repo relative
# to home.
tree_path="$(relpath "${repo_path}" "${home_path}")"

# shellcheck disable=SC2016
git -C "${repo_path}" ls-tree --name-only -z HEAD \
                                                  | xargs -0 -- sh -c "${link_body}"'
CALLER=$1 DRY_RUN=$2 treepath=$3 destpath=$4
shift 4
for filename; do
  # skip: this script, dotfiles already prefixed with ".", markdown files, and
  # XDG-specific directories that have canonical locations outside ~/.*
  case "${filename}" in
    "${CALLER}"|.*|*.md|environment.d|launchd|scripts|systemd|user-tmpfiles.d)
      continue ;;
  esac
  dst_link "${treepath:+${treepath}/}${filename}" "${destpath:+${destpath}/}.${filename}"
done
' -- "${argzero_name}" "${dry_run}" "${tree_path}" "${home_path}" || :

# Link tracked helper scripts into ~/.local/bin so they are on PATH (the
# launchd/systemd units reference them there). New scripts dropped in scripts/
# become available on the next install with no further wiring.
local_bin="${home_path}/.local/bin"
test -n "${dry_run}" || mkdir -p -- "${local_bin}"
# shellcheck disable=SC2016
git -C "${repo_path}" ls-tree --name-only -z HEAD:scripts \
                                                          | xargs -0 -- sh -c "${link_body}"'
DRY_RUN=$1 src_dir=$2 dst_dir=$3
shift 3
for filename; do
  dst_link "${src_dir}/${filename}" "${dst_dir}/${filename}"
done
' -- "${dry_run}" "$(relpath "${repo_path}/scripts" "${local_bin}")" "${local_bin}" || :

# On macOS, generate launchd plists into ~/Library/LaunchAgents. launchd needs
# absolute paths, so the tracked templates carry a __HOME__ placeholder that is
# substituted here (a symlink would leave it unresolved); each run regenerates.
case "$(uname -s)" in Darwin)
  launch_agents="${home_path}/Library/LaunchAgents"
  test -n "${dry_run}" || mkdir -p -- "${launch_agents}"
  # shellcheck disable=SC2016
  git -C "${repo_path}" ls-tree --name-only -z HEAD:launchd/agents \
                                                                   | xargs -0 -- sh -c '
dry_run=$1 src_dir=$2 dst_dir=$3 home=$4
shift 4
for filename; do
  src="${src_dir}/${filename}"
  dst="${dst_dir}/${filename}"
  if test -n "${dry_run}"; then
    printf "generate: %s (__HOME__ -> %s)\n" "${dst}" "${home}"
  else
    # rm first: a stale symlink here could point back into the repo, and
    # `sed > dst` through it would truncate the source. (No `--`: BSD sed reads
    # it as a filename; src is absolute anyway.)
    rm -f -- "${dst}"
    sed "s|__HOME__|${home}|g" "${src}" > "${dst}"
    printf "generate: %s\n" "${dst}"
  fi
done
' -- "${dry_run}" "${repo_path}/launchd/agents" "${launch_agents}" "${home_path}" || :

  # Activate now instead of at next login. Needs a GUI session (gui/$UID), so
  # probe that domain and skip over SSH. mcphub is heavyweight and stays manual.
  launch_domain="gui/$(id -u)"
  if test -z "${dry_run}" && launchctl print "${launch_domain}" > /dev/null 2>&1; then
    for plist in "${launch_agents}"/com.patrickdeyoreo.*.plist; do
      test -e "${plist}" || continue
      label="${plist##*/}"
      label="${label%.plist}"
      case "${label}" in *mcphub*) continue ;; esac
      printf "activate: %s\n" "${label}"
      # Reload cleanly: bootout then bootstrap picks up plist edits and runs
      # RunAtLoad. (`kickstart -k` instead would force-restart into launchd's
      # ~10s respawn throttle on an agent that just ran.)
      launchctl bootout "${launch_domain}/${label}" 2> /dev/null || :
      launchctl bootstrap "${launch_domain}" "${plist}" 2> /dev/null || :
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
      printf "enable: %s\n" "${unit_name}"
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
