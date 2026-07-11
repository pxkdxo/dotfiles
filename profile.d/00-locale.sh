#!/usr/bin/env sh
# Always want a UTF-8 ctype. C.UTF-8 is glibc/musl-only: macOS rejects it
# and silently degrades to plain "C".
case "$(uname -s)" in
  Darwin*) export LC_CTYPE="UTF-8" ;;
  *)       export LC_CTYPE="C.UTF-8" ;;
esac
