"""Emit one hosted server's MCP headers for Codex from an env file, in memory."""
import argparse
import json
import os
from pathlib import Path
from string import Template
import sys
from dotenv import dotenv_values
from launch_backend import expand

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--connections", type=Path, required=True)
    parser.add_argument("--env-file", type=Path, required=True)
    parser.add_argument("--server", required=True)
    args = parser.parse_args()
    if not args.env_file.is_file():
        raise ValueError("Environment file is missing")
    env = {k: v for k, v in dotenv_values(args.env_file, interpolate=False).items() if v is not None}
    env.update(os.environ)
    spec = json.loads(args.connections.read_text())["mcpServers"][args.server]
    for template in spec.get("headers", {}).values():
        if any(not env.get(name) for name in Template(template).get_identifiers()):
            raise ValueError("Header variable is empty")
    headers = expand(spec.get("headers", {}), env)
    if not headers:
        raise ValueError("Hosted server has no headers")
    sys.stdout.write(json.dumps(headers))

if __name__ == "__main__":
    try:
        main()
    except (ValueError, KeyError, OSError):
        print("Hosted MCP headers are unavailable", file=sys.stderr)
        sys.exit(2)
