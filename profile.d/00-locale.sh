#!/usr/bin/env sh
# One locale setting we *always* want: a UTF-8 character type.
# C.UTF-8 is glibc/musl/bionic-only; macOS libc rejects it and silently falls
# back to plain "C" (non-UTF-8 ctype) while perl et al. warn on every login.
case "$(uname -s)" in
  Darwin*) export LC_CTYPE="UTF-8" ;;
  *)       export LC_CTYPE="C.UTF-8" ;;
esac
