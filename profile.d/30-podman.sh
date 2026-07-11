#!/usr/bin/env sh
# ~/.profile.d/podman.sh: Configure the environment to use Podman as a Docker substitute
#
# Detection only -- no service lifecycle here. Starting the macOS podman VM
# from a login script meant every terminal tab could kick it; that now lives
# in launchd/agents/com.patrickdeyoreo.podman-machine.plist. On Linux the
# socket paths are checked directly first, so the common case sets
# DOCKER_HOST without forking podman at all.

if test -n "${DOCKER_HOST:-}"; then
  : # already configured (inherited from the session environment)
elif command -v podman > /dev/null; then
  case "$(uname -s)" in
    Linux* | linux*)
      podman_socket="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/podman/podman.sock"
      if test -S "${podman_socket}"; then
        export DOCKER_HOST="unix://${podman_socket}"
      elif test -S /run/podman/podman.sock; then
        export DOCKER_HOST='unix:///run/podman/podman.sock'
      elif podman_socket="$(
        podman info --format '{{ .Host.RemoteSocket.Path }}' 2> /dev/null
      )" && test -S "${podman_socket}"; then
        export DOCKER_HOST="unix://${podman_socket}"
      fi
      unset podman_socket
      ;;
    Darwin* | darwin*)
      if podman_socket="$(
        podman machine inspect --format '{{ .ConnectionInfo.PodmanSocket.Path }}' 2> /dev/null
      )" && test -S "${podman_socket}"; then
        export DOCKER_HOST="unix://${podman_socket}"
      fi
      unset podman_socket
      ;;
  esac
fi

# vim:ft=sh
