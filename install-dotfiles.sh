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

if test -t 0; then
  ln_replace='i'
else
  ln_replace=''
fi
ln_optchars="snrvT"

OPTIND=1
option=''
optstr=':hnif'

while getopts "${optstr}" option; do
  case "${option}" in
    'h')
      print_help
      exit 2
      ;;
    'n') ln_replace='' ;;
    'i') ln_replace='i' ;;
    'f') ln_replace='f' ;;
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

if test "$#" -gt 1; then
  printf '%s: received too many arguments\n' "${argzero_basename}" >&2
  printf 'usage: %s' "${usage}" >&2
  exit 2
fi

cd -- "${argzero_dirname}"

tree_path="$(pwd -P && printf -- '%c' '@')"
tree_path="${tree_path%?@}"

if test "$#" -eq 1; then
  home_path="$(cd -- "$1" && pwd -P && printf -- '%c' '@')"
  home_path="${home_path%?@}"
  shift
else
  home_path="$(cd && pwd -P && printf -- '%c' '@')"
  home_path="${home_path%?@}"
fi

# shellcheck disable=SC2016
git ls-tree --name-only -z HEAD | xargs -0 -n 1 -o -- sh -c '
optchars=$1
treepath=$2
destpath=$3
filename=$4
case "${filename}" in .*|*.md) exit 0 ;;
esac
set -x
ln "-${optchars}" -- "${treepath:+${treepath}/}${filename}" "${destpath:+${destpath}/}.${filename}"
' -- "${ln_replace}${ln_optchars}" "${tree_path}" "${home_path}" || :

exit 0
