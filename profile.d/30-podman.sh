#!/usr/bin/env sh
# ~/.profile.d/podman.sh: Configure the environment to use Podman as a Docker substitute

if command -v podman > /dev/null; then
  # Set DOCKER_HOST to use Podman socket
  case "$(uname -s)" in
    Linux* | linux*)
      if podman_socket="$(
        podman info --format '{{ .Host.RemoteSocket.Path }}' 2> /dev/null
      )" && test -S "${podman_socket}"; then
        export DOCKER_HOST="unix://${podman_socket}"
      elif test -S "${XDG_RUNTIME_DIR:-/run/user/${UID:-$(id -u)}}/podman/podman.sock"; then
        export DOCKER_HOST="unix://${XDG_RUNTIME_DIR:-${HOME}/.local/share}/podman/podman.sock"
      elif test -S /run/podman/podman.sock; then
        export DOCKER_HOST='unix:///run/podman/podman.sock'
      fi
      unset podman_socket
      ;;
    Darwin* | darwin*)
      # If not running, auto-start wachine in the background
      if podman_state="$(
        podman machine inspect --format '{{ .State }}' 2> /dev/null
      )" && test "${podman_state}" != running; then
        podman machine start < /dev/null > /dev/null 2>&1 &
      fi
      unset podman_state
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
