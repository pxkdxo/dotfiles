#!/bin/sh
# export-login-env.sh — publish the interactive-login shell environment (PATH,
# XDG_*, and everything profile.d sets) into the macOS GUI session via
# `launchctl setenv`, so apps launched from the Dock/Spotlight inherit the same
# environment as a terminal. macOS does not hand the shell environment to GUI
# apps; this is the counterpart to environment.d on Linux. Run at login by
# com.patrickdeyoreo.setenv, and safe to re-run any time.
#
# A POSIX login shell (sh -l) sources /etc/profile and ~/.profile (-> the repo
# `profile`, which loads profile.d/*.sh) — shell-agnostic, matching profile.d's
# POSIX nature — but not zshrc, so ~/.env (secrets) is excluded.
set -u

command -v launchctl >/dev/null 2>&1 || exit 0 # macOS only

# Absolute /usr/bin/env: a bare `env` may resolve to ~/.local/bin/env (a uv/rust
# PATH shim), not the coreutil that dumps the environment.
sh -lc /usr/bin/env 2>/dev/null | while IFS='=' read -r name value; do
  case "${name}" in
  # blanks and continuation lines from multi-line values
  '' | *[!A-Za-z0-9_]*) continue ;;
  # identity / volatile / shell-internal — wrong to pin in the GUI session
  HOME | USER | LOGNAME | SHELL | PWD | OLDPWD | SHLVL | _ | TMPDIR) continue ;;
  # terminal- and session-specific
  TERM | TERMINFO | COLORTERM | SECURITYSESSIONID) continue ;;
  SSH_* | XPC_* | __CF* | TERM_*) continue ;;
  esac
  launchctl setenv "${name}" "${value}" 2>/dev/null || :
done
