"""Generate secret-free proxy/client connection files from one mcpServers inventory."""
import argparse
import json
import shlex
from pathlib import Path
from string import Template
import sys
from urllib.parse import quote
from service import private_json, NAME

ROOT=Path(__file__).resolve().parent

def generate(inventory, output, port):
    data=json.loads(inventory.read_text())
    entries=data["mcpServers"]
    local={}
    connections={}
    codex=[]
    for name,spec in entries.items():
        if not NAME.fullmatch(name): raise ValueError("Invalid stable server name: "+name)
        if not spec.get("enabled",True): continue
        if "url" not in spec:
            local[name]={"command":sys.executable,"args":[str(ROOT/"launch_backend.py"),str(inventory),name]}
            url=f"http://127.0.0.1:{port}/servers/{quote(name,safe='')}/mcp"
            connections[name]={"type":"http","url":url}
            codex.extend([f"[mcp_servers.{name}]", "url = "+json.dumps(url), ""])
        else:
            # Hosted endpoint and headers remain templates; connection consumers resolve at runtime.
            connections[name]={"type":"http","url":spec["url"],"headers":spec.get("headers",{})}
            if Template(spec["url"]).get_identifiers():
                raise ValueError("Codex hosted endpoint URLs must be literal; credentials belong in headers")
            codex.extend([f"[mcp_servers.{name}]", "url = "+json.dumps(spec["url"])])
            for value in spec.get("headers",{}).values():
                if not isinstance(value,str) or not Template(value).is_valid() or not Template(value).get_identifiers():
                    raise ValueError("Hosted headers must use variable placeholders")
            if spec.get("headers"):
                helper=shlex.join([sys.executable,str(ROOT/"codex_headers.py"),
                    "--connections",str(output/"connections.json"),
                    "--env-file",str(Path.home()/".env"),"--server",name])
                codex.append("http_headers_helper = "+json.dumps(helper))
            codex.append("")
    output.mkdir(parents=True,exist_ok=True,mode=0o700)
    private_json(output/"proxy.json",{"mcpServers":local})
    private_json(output/"connections.json",{"mcpServers":connections})
    (output/"codex-mcp.toml").write_text("\n".join(codex))
    return len(local),len(connections)-len(local)

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("--inventory",type=Path,required=True)
    p.add_argument("--output",type=Path,required=True)
    p.add_argument("--port",type=int,default=37373)
    a=p.parse_args()
    if not 0<a.port<65536: p.error("Invalid port")
    local,hosted=generate(a.inventory.resolve(),a.output.resolve(),a.port)
    print(f"Generated {local} shared-local and {hosted} hosted connections; no credentials resolved")
if __name__=="__main__": main()
