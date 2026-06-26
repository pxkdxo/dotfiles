#!/bin/sh
# detect-term-bg.sh — report whether the terminal background looks "light" or
# "dark" by querying its background color with OSC 11.
#
# Dual purpose:
#   * SOURCE it  -> defines detect_term_bg(); no other side effects.
#                   Lets a shell call it in-process, with no extra shell spawn.
#   * EXECUTE it -> prints the verdict. Add -q/--quiet for just "light"/"dark".
#
# The function body is POSIX sh. The only shell-specific bits are guarded:
#   * `local` for scoping (ubiquitous, though not strictly POSIX),
#   * `emulate sh` under zsh so unquoted word-splitting matches POSIX when the
#     function is called in-process from an interactive zsh,
#   * the sourced-vs-executed test, which inspects zsh/bash internals.

detect_term_bg() {
  # zsh does not word-split unquoted expansions by default; match POSIX so the
  # `set -- $rgb` split below behaves the same in-process as under /bin/sh.
  if [ -n "${ZSH_VERSION-}" ]; then
    emulate -L sh 2>/dev/null
  fi

  # Need a usable terminal and a controlling tty to talk to.
  case "${TERM-}" in
  '' | dumb) return 1 ;;
  esac
  {
    : </dev/tty
  } 2>/dev/null || return 1

  local saved reply rest comp rgb r g b lightness bel oldifs
  saved="$(stty -g </dev/tty 2>/dev/null)" || return 1

  # min 0 + time 2 = non-canonical read with a 0.2s timeout (tenths of a
  # second). A read that times out with no data returns EOF, so a single dd
  # collects the whole reply and stops shortly after the last byte — or
  # immediately if the terminal ignores the query.
  stty -echo -icanon min 0 time 2 </dev/tty
  # Multiplexers (tmux 3.x, Zellij) answer OSC 11 themselves, so a plain query
  # works inside them with no passthrough wrapping.
  printf '\033]11;?\007' >/dev/tty
  reply="$(dd if=/dev/tty bs=1 count=64 2>/dev/null)"
  stty "$saved" </dev/tty 2>/dev/null

  # Strip the trailing terminator (BEL or ST) from the reply, if present.
  bel="$(printf '\007')"
  reply="${reply%%"$bel"*}"

  case "$reply" in
  *rgb:*)
    rest="${reply#*rgb:}"          # RRRR/GGGG/BBBB
    rest="${rest%%[!0-9A-Fa-f/]*}" # drop any junk after the color
    ;;
  *)
    return 1
    ;;
  esac

  # Split RRRR/GGGG/BBBB into three hex components.
  oldifs="$IFS"
  IFS='/'
  # shellcheck disable=SC2086 # deliberate word-splitting on IFS
  set -- $rest
  IFS="$oldifs"
  [ "$#" -ge 3 ] || return 1

  # Reduce each component (1, 2, 3, or 4 hex digits) to its high 8 bits.
  rgb=
  for comp in "$1" "$2" "$3"; do
    case "${#comp}" in
    1) comp="$comp$comp" ;;               # 4-bit -> duplicate nibble
    2) ;;                                 # already 8-bit
    3 | 4) comp="${comp%"${comp#??}"}" ;; # keep the high byte
    *) return 1 ;;
    esac
    rgb="$rgb $((0x$comp))"
  done
  set -- $rgb
  r=$1 g=$2 b=$3

  # Rec. 709 perceived brightness, 0..255.
  lightness="$(((2126 * r + 7152 * g + 722 * b) / 10000))"
  if [ "$lightness" -ge 128 ]; then
    printf 'light\n'
  else
    printf 'dark\n'
  fi
}

detect_term_bg__main() {
  case "${1-}" in
  -q | --quiet)
    detect_term_bg
    ;;
  '')
    verdict="$(detect_term_bg)" || return $?
    printf 'Terminal background looks %s.\n' "$verdict"
    ;;
  *)
    printf 'usage: %s [-q|--quiet]\n' "${0##*/}" >&2
    return 64
    ;;
  esac
}

# Run only when executed directly, not when sourced. The sourced-vs-executed
# test covers zsh and bash (the shells we source into); under a bare POSIX sh
# the file is meant to be executed, so falling through to main is correct.
detect_term_bg__sourced=0
if [ -n "${ZSH_VERSION-}" ]; then
  case "${ZSH_EVAL_CONTEXT-}" in
  *file*) detect_term_bg__sourced=1 ;;
  esac
elif [ -n "${BASH_VERSION-}" ]; then
  [ "${BASH_SOURCE-}" != "${0-}" ] && detect_term_bg__sourced=1
fi

if [ "$detect_term_bg__sourced" -eq 0 ]; then
  detect_term_bg__main "$@"
  exit $?
fi
unset -f detect_term_bg__main 2>/dev/null
unset detect_term_bg__sourced
