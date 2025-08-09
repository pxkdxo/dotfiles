if command -v podman > /dev/null
then
  case "$(uname -s)" in
    Linux)
      export DOCKER_HOST='unix:///run/podman/podman.sock'
      ;;
    Darwin)
      DOCKER_HOST="$(podman machine inspect --format '{{ .ConnectionInfo.PodmanSocket.Path }}' 2> /dev/null)" &&
      export DOCKER_HOST
      ;;
  esac
fi
