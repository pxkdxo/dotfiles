"""Standard-library template expansion at exec time; expanded values stay in memory."""
import json
import os
from pathlib import Path
from string import Template
import sys

BASE_ENV = ("PATH", "HOME", "TMPDIR", "USER", "LANG", "LC_ALL",
            "XDG_CACHE_HOME", "XDG_CONFIG_HOME", "XDG_DATA_HOME", "XDG_STATE_HOME")

def expand(value, env):
    if isinstance(value, str):
        template = Template(value)
        if not template.is_valid():
            raise ValueError("Invalid variable template")
        # Names only in diagnostics, never template text or substituted values.
        for name in template.get_identifiers():
            if name not in env:
                raise ValueError("Required environment variable is missing: " + name)
        return template.substitute(env)
    if isinstance(value, list):
        return [expand(v, env) for v in value]
    if isinstance(value, dict):
        return {k: expand(v, env) for k, v in value.items()}
    return value

def prepare(spec, source):
    resolved = expand(spec, source)
    if not isinstance(resolved.get("command"), str) or not resolved["command"]:
        raise ValueError("Server command is required")
    args = resolved.get("args", [])
    if not isinstance(args, list) or not all(isinstance(v,str) for v in args):
        raise ValueError("Server arguments must be strings")
    values = resolved.get("env", {})
    if not isinstance(values, dict) or not all(isinstance(k,str) and isinstance(v,str) for k,v in values.items()):
        raise ValueError("Server env must map names to strings")
    # Empty settings are allowed; variable-backed backend environment entries must be nonempty.
    for key, original in spec.get("env", {}).items():
        if isinstance(original,str) and Template(original).get_identifiers() and not values[key]:
            raise ValueError("Required server environment value is empty: " + key)
    child = {k: source[k] for k in spec.get("inherit", BASE_ENV) if k in source}
    child.update(values)
    return resolved, child

def main():
    spec = json.loads(Path(sys.argv[1]).read_text())["mcpServers"][sys.argv[2]]
    resolved, child = prepare(spec, dict(os.environ))
    if resolved.get("cwd"):
        os.chdir(resolved["cwd"])
    os.execvpe(resolved["command"], [resolved["command"], *resolved.get("args",[])], child)

if __name__ == "__main__":
    try:
        main()
    except (ValueError, KeyError, OSError) as error:
        # Do not render OSError paths: commands/paths may carry substituted values.
        print(str(error) if isinstance(error,ValueError) else type(error).__name__, file=sys.stderr)
        sys.exit(2)
