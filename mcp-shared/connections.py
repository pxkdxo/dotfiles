"""Resolve connection templates only in memory for Neovim/ACP consumption."""
import argparse
import json
import os
from pathlib import Path
import sys
from string import Template
from dotenv import dotenv_values
from launch_backend import expand

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--connections",type=Path,required=True)
    parser.add_argument("--env-file",type=Path)
    parser.add_argument("--local-only",action="store_true")
    args=parser.parse_args()
    env={}
    if args.env_file:
        if not args.env_file.is_file():
            raise ValueError("Environment file is missing")
        env.update({k:v for k,v in dotenv_values(args.env_file,interpolate=False).items() if v is not None})
    env.update(os.environ)
    data=json.loads(args.connections.read_text())["mcpServers"]
    acp=[]
    for name,spec in data.items():
        if args.local_only and not spec["url"].startswith("http://127.0.0.1:"):
            continue
        for template in spec.get("headers",{}).values():
            if any(not env.get(key) for key in Template(template).get_identifiers()):
                raise ValueError("Connection header variable is empty")
        entry=expand(spec,env)
        acp.append({"name":name,"type":"http","url":entry["url"],
                    "headers":[{"name":k,"value":v} for k,v in entry.get("headers",{}).items()]})
    # stdout is intentionally a private pipe to the consuming app, never a generated file or log.
    sys.stdout.write(json.dumps(acp))
if __name__=="__main__":
    try: main()
    except (ValueError,KeyError):
        print("Connection variables are missing or invalid",file=sys.stderr); sys.exit(2)
