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

${argzero_name} - bootstrap the dotfiles layout in a user's home directory

Establishes the canonical tree on every platform (systemd Linux, macOS,
termux):

  ~/.local/etc          the repository (physically, or a symlink to this
                        checkout) -- this is XDG_CONFIG_HOME
  ~/.local/var          the state tree (XDG_STATE_HOME), with cache at
                        ~/.local/var/cache and tmp at ~/.local/var/tmp
  ~/.config, ~/.cache, ~/.local/state
                        compat symlinks into the tree

Then links home-convention files (shell rc, gnupg, inputrc, vim, X session
files, ...) as ~/.<name>, links scripts/ into ~/.local/bin, removes stale
~/.<name> links from earlier layouts, and registers services (systemd user
units on Linux, launchd agents on macOS).

Migrations are automatic and nothing is ever deleted: a real ~/.config
migrates entry-by-entry into the repo tree (repo wins collisions), ~/.cache
and ~/.local/state fold into the var tree; displaced entries land in
*.migrated aside directories. The one refusal: a populated ~/.local/etc that
is not this checkout.

The run is idempotent and non-interactive; nothing prompts. "-n" previews
every action without touching the filesystem or any service manager.
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

# phys DIR — print DIR's physical path (symlinks resolved), empty if absent
phys() {
  (cd -P -- "$1" 2> /dev/null && pwd -P) || :
}

# dir_empty DIR — true when DIR exists and contains nothing
dir_empty() {
  test -d "$1" && test -z "$(ls -A -- "$1" 2> /dev/null)"
}

# note ACTION — print an action line (both real and dry runs print; dry runs
# print INSTEAD of acting)
note() {
  printf '%s\n' "$*"
}

refuse() {
  >&2 printf '%s: refusing: %s\n' "${argzero_name}" "$1"
  shift
  for _refuse_line; do >&2 printf '  %s\n' "${_refuse_line}"; done
  exit 1
}

# Bootstrap the canonical tree. user-tmpfiles.d mirrors this on systemd
# Linux but is create-only (login must never delete data): all migration
# happens here. macOS/termux have no tmpfiles; this is what builds the tree.

for dirname in .local .local/bin .local/share .local/var .local/var/cache \
  .local/var/log .local/var/tmp; do
  test -d "${home_path}/${dirname}" && continue
  note "mkdir: ${home_path}/${dirname}"
  test -n "${dry_run}" || mkdir -p -- "${home_path}/${dirname}"
done

local_etc="${home_path}/.local/etc"
config_dir="${home_path}/.config"
repo_phys="$(phys "${repo_path}")"

# Place the repo at ~/.local/etc: keep an in-place checkout, else (re)point
# a symlink here. A populated foreign directory is a human's call.
if test "$(phys "${local_etc}")" = "${repo_phys}" && test -n "${repo_phys}"; then
  : # already in place
elif test -L "${local_etc}" || ! test -e "${local_etc}"; then
  note "link: ${local_etc} -> ${repo_phys}"
  test -n "${dry_run}" || ln -sfn -- "$(relpath "${repo_phys}" "${home_path}/.local")" "${local_etc}"
elif dir_empty "${local_etc}"; then
  note "replace empty directory: ${local_etc} -> ${repo_phys}"
  test -n "${dry_run}" || {
    rmdir -- "${local_etc}"
    ln -s -- "$(relpath "${repo_phys}" "${home_path}/.local")" "${local_etc}"
  }
else
  refuse "~/.local/etc is a populated directory that is not this checkout" \
    "Run the installer from that tree instead:  cd ${local_etc} && ./${argzero_name}" \
    "or reconcile the two trees by hand, then re-run."
fi

# ~/.config: alias for the repo tree. A real ~/.config migrates entry-by-
# entry into the repo (untracked app config cohabits; .gitignore is an
# allowlist). Repo wins collisions; the displaced entry is set aside.
if test "$(phys "${config_dir}")" = "${repo_phys}"; then
  : # ~/.config already reaches the repo (as the checkout itself or via link)
elif test -L "${config_dir}" || ! test -e "${config_dir}"; then
  note "link: ${config_dir} -> ${local_etc}"
  test -n "${dry_run}" || ln -sfn -- '.local/etc' "${config_dir}"
elif test -d "${config_dir}"; then
  config_aside="${config_dir}.migrated"
  for entry in "${config_dir}"/* "${config_dir}"/.[!.]* "${config_dir}"/..?*; do
    test -e "${entry}" || test -L "${entry}" || continue
    entry_name="${entry##*/}"
    if test -e "${repo_phys}/${entry_name}" || test -L "${repo_phys}/${entry_name}"; then
      note "set aside (repo wins): ${entry} -> ${config_aside}/"
      test -n "${dry_run}" || {
        mkdir -p -- "${config_aside}"
        mv -- "${entry}" "${config_aside}/"
      }
    else
      note "migrate: ${entry} -> ${repo_phys}/"
      test -n "${dry_run}" || mv -- "${entry}" "${repo_phys}/"
    fi
  done
  note "link: ${config_dir} -> ${local_etc}"
  test -n "${dry_run}" || {
    rmdir -- "${config_dir}"
    ln -s -- '.local/etc' "${config_dir}"
  }
  if test -d "${config_aside}"; then
    note "NOTE: displaced config entries preserved in ${config_aside}; review and delete at leisure."
  fi
fi

# ~/.cache: adopt into ~/.local/var/cache. Non-colliding entries move;
# collisions are set aside, never deleted.
cache_dir="${home_path}/.cache"
var_cache="${home_path}/.local/var/cache"
if test "$(phys "${cache_dir}")" = "$(phys "${var_cache}")" && test -n "$(phys "${cache_dir}")"; then
  : # already unified
elif test -L "${cache_dir}" || ! test -e "${cache_dir}"; then
  note "link: ${cache_dir} -> ${var_cache}"
  test -n "${dry_run}" || ln -sfn -- '.local/var/cache' "${cache_dir}"
elif test -d "${cache_dir}"; then
  cache_aside="${cache_dir}.migrated"
  for entry in "${cache_dir}"/* "${cache_dir}"/.[!.]* "${cache_dir}"/..?*; do
    test -e "${entry}" || test -L "${entry}" || continue
    basename="${entry##*/}"
    if test -e "${var_cache}/${basename}" || test -L "${var_cache}/${basename}"; then
      note "set aside (name collision): ${entry} -> ${cache_aside}/"
      test -n "${dry_run}" || {
        mkdir -p -- "${cache_aside}"
        mv -- "${entry}" "${cache_aside}/"
      }
    else
      note "adopt: ${entry} -> ${var_cache}/"
      test -n "${dry_run}" || mv -- "${entry}" "${var_cache}/"
    fi
  done
  # bash history is the one non-disposable file under the cache tree: if a
  # collision parked it, append its content to the adopted copy.
  if test -f "${cache_aside}/bash/history" && test -f "${var_cache}/bash/history"; then
    note "append set-aside bash history into ${var_cache}/bash/history"
    test -n "${dry_run}" || cat -- "${cache_aside}/bash/history" >> "${var_cache}/bash/history"
  fi
  note "link: ${cache_dir} -> ${var_cache}"
  test -n "${dry_run}" || {
    rmdir -- "${cache_dir}"
    ln -s -- '.local/var/cache' "${cache_dir}"
  }
  if test -d "${cache_aside}"; then
    note "NOTE: collided cache entries preserved in ${cache_aside}; review and delete at leisure."
  fi
fi

# ~/.local/state: fold into ~/.local/var. The var copy wins collisions (it
# is the tree systemd sessions write to); the state-side entry is set aside.
state_dir="${home_path}/.local/state"
var_dir="${home_path}/.local/var"
if test "$(phys "${state_dir}")" = "$(phys "${var_dir}")" && test -n "$(phys "${state_dir}")"; then
  : # already unified
elif test -L "${state_dir}" || ! test -e "${state_dir}"; then
  note "link: ${state_dir} -> ${var_dir}"
  test -n "${dry_run}" || ln -sfn -- 'var' "${state_dir}"
elif test -d "${state_dir}"; then
  state_aside="${state_dir}.migrated"
  for entry in "${state_dir}"/* "${state_dir}"/.[!.]* "${state_dir}"/..?*; do
    test -e "${entry}" || test -L "${entry}" || continue
    entry_name="${entry##*/}"
    if test -e "${var_dir}/${entry_name}" || test -L "${var_dir}/${entry_name}"; then
      note "set aside (name collision): ${entry} -> ${state_aside}/"
      test -n "${dry_run}" || {
        mkdir -p -- "${state_aside}"
        mv -- "${entry}" "${state_aside}/"
      }
    else
      note "migrate: ${entry} -> ${var_dir}/"
      test -n "${dry_run}" || mv -- "${entry}" "${var_dir}/"
    fi
  done
  note "link: ${state_dir} -> ${var_dir}"
  test -n "${dry_run}" || {
    rmdir -- "${state_dir}"
    ln -s -- 'var' "${state_dir}"
  }
  if test -d "${state_aside}"; then
    note "NOTE: collided state entries preserved in ${state_aside}; review and delete at leisure."
  fi
fi

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

# Only home-convention files get a ~/.<name> link; XDG-app configs are
# reached via ~/.config and their tools never read ~/.<name> (~/.tmux.conf
# even broke theming: tmux resolves #{d:current_file} to $HOME through the
# link). Stale links from older layouts are removed only when provably ours.
# shellcheck disable=SC2016
git -C "${repo_path}" ls-tree --name-only -z HEAD \
                                                  | xargs -0 -- sh -c "${link_body}"'
CALLER=$1 DRY_RUN=$2 treepath=$3 destpath=$4
shift 4
for filename; do
  dst="${destpath:+${destpath}/}.${filename}"
  case "${filename}" in
    bash_completion | bash_completion.d | bash_logout | bash_profile | bashrc \
      | bashrc.d | dircolors | gnupg | inputrc | npmrc | profile | termux \
      | vim | xinitrc | xprofile | xserverrc | xsession | Xresources \
      | Xresources.d | zlogin | zlogout | zprofile | zshenv | zshrc)
      dst_link "${treepath:+${treepath}/}${filename}" "${dst}"
      ;;
    "${CALLER}" | .* | *.md | environment.d | launchd | scripts | systemd | user-tmpfiles.d)
      ;;
    *)
      # formerly linked as ~/.<name>; remove exactly our own stale link
      if test -L "${dst}" \
        && test "$(readlink -- "${dst}")" = "${treepath:+${treepath}/}${filename}"; then
        printf "unlink stale: %s\n" "${dst}"
        test -n "${DRY_RUN}" || rm -- "${dst}"
      fi
      ;;
  esac
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
  # Apply user tmpfiles now: immediate effect, and some distros never enable
  # the user-scope setup service.
  if test -z "${dry_run}" && command -v systemd-tmpfiles > /dev/null 2>&1; then
    printf 'apply: systemd-tmpfiles --user --create\n'
    systemd-tmpfiles --user --create 2> /dev/null || :
  fi
  if command -v systemctl > /dev/null 2>&1; then
    test -n "${dry_run}" || systemctl --user daemon-reload 2> /dev/null || :
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
      test -n "${dry_run}" && continue # -n previews without touching anything
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
