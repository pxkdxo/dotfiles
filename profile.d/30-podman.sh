#!/usr/bin/env sh
# ~/.profile.d/podman.sh: Configure the environment to use Podman as a Docker substitute
#
# Detection only: the macOS VM is started by the podman-machine launchd
# agent, never by login shells. Socket paths are checked before ever forking
# podman.

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
