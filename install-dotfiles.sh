#!/usr/bin/env sh
# install-dotfiles.sh
#
# Create symbolic links in the invoking user's home directory for
# each file and directory tracked at the top level of this repository.
# The name of the link will match the name of the file it links to,
# prefixed with a period ('.').


set -o errexit

argzero_basename="${0##*/}"
argzero_dirname="${0%"${argzero_basename}"}"
argzero_dirname="${argzero_dirname:-.}"


usage="${argzero_basename} [-n|-i|-f] [--] [TARGET_DIRECTORY]"


print_help() {
  cat << EOF
usage: ${usage}

${argzero_basename} - link dotfiles into a user's home directory

Create symbolic links in the invoking user's home directory for
each file and directory tracked at the top level of this repository.
The name of the link will match the name of the file it links to,
prefixed with a period ('.').

The options "-n", "-i", and "-f", control whether or not existing files
are replaced. With "-n", no files are replaced. With "-i", the user is
prompted interactively for any file that would be replaced. With "-f",
the user is not prompted and files are replaced.
EOF
}


ln_optchars="snv"

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
      exit 2
      ;;
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
    'n') ln_replace='' ;;
    'i') ln_replace='i' ;;
    'f') ln_replace='f' ;;
  esac
done
shift "$((OPTIND - 1))"


if test "$#" -gt 1; then
  printf '%s: received too many arguments\n' "${argzero_basename}" >&2
  printf 'usage: %s' "${usage}" >&2
  exit 2
fi


if test "$#" -eq 1; then
  home_path="$(cd -- "$1" && pwd -P && printf '%c' '@')"
  home_path="${home_path%?@}"
  shift
else
  home_path="$(cd && pwd -P && printf '%c' '@')"
  home_path="${home_path%?@}"
fi


tree_path="$(cd -- "${argzero_dirname}" && pwd -P && printf '%c' '@')"
tree_path="${tree_path%?@}"


rel_to_ancestor=""
next_parent_dir="${home_path%/}"
while test "${next_parent_dir}" != ''; do
  next_parent_dir="${next_parent_dir%/*}"
  rel_to_ancestor="${rel_to_ancestor}../"
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
  tree_path="${rel_to_ancestor}${tree_path#/}"
fi


ln_optchars="${ln_optchars}${ln_replace}"


# shellcheck disable=SC2016
git ls-tree --name-only -z HEAD | xargs -0 -n 1 -o -- sh -c '
installer=$1
optchars=$2
treepath=$3
destpath=$4
filename=$5
case "${filename}" in ("${installer}"|.*|*.md) exit 0 ;;
esac
set -x
ln "-${optchars}" -- "${treepath:+${treepath}/}${filename}" "${destpath:+${destpath}/}.${filename}"
' -- "${argzero_basename}" "${ln_optchars}" "${tree_path}" "${home_path}" || :

exit 0
