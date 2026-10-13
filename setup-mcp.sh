#!/usr/bin/env sh
# Explicit network/dependency setup; the base installer remains offline and fast.

set -eu

MCP_REPO=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd -P)
PYTHON_VERSION=3.13

command -v uv >/dev/null 2>&1 || {
  echo 'Missing required dependency: uv' >&2
  exit 2
}
if ! test -x "${MCP_REPO}/mcp-shared/.venv/bin/python"; then
  uv venv --python "${PYTHON_VERSION}" "${MCP_REPO}/mcp-shared/.venv"
fi
uv pip sync --python "${MCP_REPO}/mcp-shared/.venv/bin/python" "${MCP_REPO}/mcp-shared/requirements.lock"
exec "${MCP_REPO}/mcp-shared/.venv/bin/python" "${MCP_REPO}/mcp-shared/setup.py" "$@"
