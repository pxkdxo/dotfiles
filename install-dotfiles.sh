#!/usr/bin/env sh
#
# Create a symlink in the home directory for each top-level file in this repository, prefixing the filename of each link with a dot.

set -o errexit

argzero_basename="${0##*/}"
argzero_dirname="${0%"${argzero_basename}"}"
argzero_dirname="${argzero_dirname:-.}"

cd -- "${argzero_dirname}"

tree_abspath="$(pwd -P)"
home_abspath="$(cd && pwd -P)"

case "${tree_abspath}" in
  "${home_abspath}")
    tree_relative_to_home_path="."
    ;;
  "${home_abspath}"/*)
    tree_relative_to_home_path="${tree_abspath#"${home_abspath}/"}"
    ;;
  *)
    tree_relative_to_home_path="${home_abspath#"${tree_abspath}/"}"
    ;;
esac

git ls-tree --name-only -z HEAD | xargs -0 -n 1 -I '{}' -o -- sh -c '
case "$3" in (.*|*.md) exit 0 ;;
esac
set -x
ln -snfbv -- "$1/$3" "$2/.$3"
' -- "${tree_relative_to_home_path}" "${home_abspath}" '{}' || :

exit 0
