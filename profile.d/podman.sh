#!/usr/bin/env sh
# ~/.profile.d/podman.sh: Configure the environment to use Podman as a Docker substitute

if command -v podman > /dev/null; then
  # Set DOCKER_HOST to use Podman socket
  case "$(uname -s)" in
    Linux)
      if test -S /run/podman/podman.sock; then
        export DOCKER_HOST='unix:///run/podman/podman.sock'
      elif test -S "${XDG_RUNTIME_DIR:-${HOME}/.local/share}/podman/podman.sock"; then
        export DOCKER_HOST="unix://${XDG_RUNTIME_DIR:-${HOME}/.local/share}/podman/podman.sock"
      fi
      ;;
    Darwin)
      podman_socket="$(podman machine inspect --format '{{ .ConnectionInfo.PodmanSocket.Path }}' 2> /dev/null)"
      if test -n "${podman_socket}" && test -S "${podman_socket}"; then
        export DOCKER_HOST="unix://${podman_socket}"
      fi
      unset podman_socket
      ;;
  esac
  case "$(podman machine inspect --format '{{ .State }}' 2>| /dev/null)" in
    running)
      ;;
    *)
      podman machine start --no-info --quiet > /dev/null
      ;;
  esac
fi

# vim:ft=sh
