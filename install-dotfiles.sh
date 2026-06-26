#!/usr/bin/env sh
# install-dotfiles.sh
#
# For each file and directory tracked at the top level of this repository,
# create a symbolic link in the invoking user's home directory. The name
# of the link will match the name of the file it links to, prefixed with
# a period ('.').

set -o errexit -o pipefail

argzero_name="${0##*/}"
argzero_dirname="${0%"${argzero_name}"}"
argzero_dirname="${argzero_dirname:-.}"

usage="${argzero_name} [-n|-i|-f] [--] [TARGET_DIRECTORY]"

print_help()
             {
  cat << EOF
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
}

ln_opts="snv"  # -s symlink, -n no-dereference, -v verbose

if test -t 0; then
  ln_replace='i'
else
  ln_replace=''
fi

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
    'n') ln_replace='' ;;
    'i') ln_replace='i' ;;
    'f') ln_replace='f' ;;
  esac
done
shift "$((OPTIND - 1))"

ln_opts="${ln_opts}${ln_replace}"

if test "$#" -gt 1; then
  printf '%s: received too many arguments\n' "${argzero_name}" >&2
  printf 'usage: %s\n' "${usage}" >&2
  exit 2
fi

if test "$#" -eq 0; then
  home_path="$(cd 2> /dev/null && pwd -P && echo '@')"
  home_path="${home_path%?@}"
else
  home_path="$(cd -- "$1" > /dev/null && pwd -P && echo '@')"  # suppress CDPATH stdout noise
  home_path="${home_path%?@}"
  shift
fi

tree_path="$(cd -- "${argzero_dirname}" > /dev/null && pwd -P && echo '@')"  # suppress CDPATH stdout noise
tree_path="${tree_path%?@}"
repo_path="${tree_path}"

# Compute tree_path relative to home_path so symlinks are relative rather
# than absolute, keeping dotfiles portable across home directory renames.
rel_to_ancestor="./"
next_parent_dir="${home_path%/}"
while test -n "${next_parent_dir}"; do
  rel_to_ancestor="${rel_to_ancestor}../"
  next_parent_dir="${next_parent_dir%/*}"
done

common_ancestor="/"
next_descendant="${home_path%"/${home_path#/*/}"}"
while test "${common_ancestor}" != "${home_path}"; do
  case "${tree_path}/" in
    "${next_descendant}"/*)
      common_ancestor="${next_descendant}"
      next_descendant="${home_path%"/${home_path#"${next_descendant}"/*/}"}"
      rel_to_ancestor="${rel_to_ancestor%../}"
      ;;
    *)
      break
      ;;
  esac
done

if test "${common_ancestor}" != '/'; then
  tree_path="${tree_path#"${common_ancestor}"}"
  tree_path="${rel_to_ancestor%/}/${tree_path#/}"
fi

# shellcheck disable=SC2016
git -C "${repo_path}" ls-tree --name-only -z HEAD | xargs -0 -n 1 -o -- sh -c '
caller=$1
optchars=$2
treepath=$3
destpath=$4
filename=$5
# skip: this script, dotfiles already prefixed with '.', markdown files, and
# XDG-specific directories that have canonical locations outside ~/.*
case "${filename}" in
  "${caller}"|.*|*.md|environment.d|launchd|systemd|user-tmpfiles.d)
    exit 0
    ;;
esac
ln "-${optchars}" -- "${treepath:+${treepath}/}${filename}" "${destpath:+${destpath}/}.${filename}" \
  || case "${optchars}" in *f*) exit 1 ;; esac
' -- "${argzero_name}" "${ln_opts}" "${tree_path}" "${home_path}"

# On macOS, link launchd agent plists into ~/Library/LaunchAgents
case "$(uname -s)" in Darwin)
  launch_agents="${home_path}/Library/LaunchAgents"
  mkdir -p -- "${launch_agents}"
  # shellcheck disable=SC2016
  git -C "${repo_path}" ls-tree --name-only -z HEAD:launchd/agents \
    | xargs -0 -n 1 -o -- sh -c '
optchars=$1
src_dir=$2
dst_dir=$3
filename=$4
ln "-${optchars}" -- "${src_dir}/${filename}" "${dst_dir}/${filename}" || :
' -- "${ln_opts}" "${repo_path}/launchd/agents" "${launch_agents}" || :
  ;;
esac

exit
