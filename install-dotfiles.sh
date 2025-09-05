#!/usr/bin/env sh
# install-dotfiles.sh
# Create symbolic links in the invoking user's home directory for each
# top-level file and directory tracked by this repository. The name of
# the link will match the name of the target, prefixed by a period ('.').

set -o errexit

argzero_basename="${0##*/}"
argzero_dirname="${0%"${argzero_basename}"}"
argzero_dirname="${argzero_dirname:-.}"

usage="${argzero_basename} [-nifb] [-S suffix]"

print_help() {
  cat << EOF
usage: ${usage}

${argzero_basename} - link dotfiles into a user's home directory

Create symbolic links in the invoking user's home directory for each
top-level file and directory tracked by this repository. The name of
the link will match the name of the target, prefixed by a period ('.').
EOF
}

opt_backup=''
opt_suffix=''
if test -t 0; then
  opt_overwrite='--interactive'
else
  opt_overwrite=''
fi

OPTIND=1
option=''
optstr=':hnifbS:'

while getopts "${optstr}" option; do
  case "${option}" in
    'h')
      print_help
      exit 2
      ;;
    'n') opt_overwrite='' ;;
    'i') opt_overwrite='--interactive' ;;
    'f') opt_overwrite='--force' ;;
    'b') opt_backup='--backup' ;;
    'S') opt_suffix="--suffix=${OPTARG}" ;;
    '?')
      printf '%s: -%c: unrecognized option\n' "${argzero_basename}" "${OPTARG}" >&2
      printf 'usage: %s' "${usage}" >&2
      exit 2
      ;;
    ':')
      printf '%s: -%c: missing required argument\n' "${argzero_basename}" "${OPTARG}" >&2
      printf 'usage: %s' "${usage}" >&2
      exit 2
      ;;
  esac
done
shift "$((OPTIND - 1))"

if test "$#" -ne 0; then
  printf '%s: received too many arguments\n' "${argzero_basename}" >&2
  printf 'usage: %s' "${usage}" >&2
  exit 2
fi

set --
if test -n "${opt_backup}"; then
  set -- "$@" "${opt_backup}"
fi
if test -n "${opt_suffix}"; then
  set -- "$@" "${opt_suffix}"
fi
if test -n "${opt_overwrite}"; then
  set -- "$@" "${opt_overwrite}"
fi

cd -- "${argzero_dirname}"

tree_path="$(pwd -P && printf -- '%c' '@')"
tree_path="${tree_path%?@}"
home_path="$(cd && pwd -P && printf -- '%c' '@')"
home_path="${home_path%?@}"

# shellcheck disable=SC2016
git ls-tree --name-only -z HEAD | xargs -0 -n 1 -I '{}' -o -- sh -c '
case "$1" in (.*|*.md) exit 0 ;;
esac
target="$1/$3"
link="$2/.$3"
shift 3
set -x
ln "$@" --verbose --symbolic --relative --no-dereference -T -- "${target}" "${link}"
' -- "${tree_path}" "${home_path}" '{}' "$@" 2>&1 || :

exit 0
