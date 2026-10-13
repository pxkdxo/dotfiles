"""Small loopback service runner: preflight, health checks, bounded restarts, cleanup."""
import argparse
import asyncio
from collections import deque
from contextlib import suppress
import fcntl
import json
import logging
import os
from pathlib import Path
import re
import signal
import socket
import subprocess
import sys
import time
from dotenv import dotenv_values
from mcp import ClientSession
from mcp.client.streamable_http import streamablehttp_client
from launch_backend import prepare

ROOT=Path(__file__).resolve().parent
LOG=logging.getLogger("shared-mcp")
NAME=re.compile(r"^[a-z][a-z0-9_-]*$")

def read_inventory(path, env):
    data=json.loads(path.read_text())
    entries=data.get("mcpServers")
    if not isinstance(entries,dict):
        raise ValueError("Inventory requires mcpServers map")
    local={}
    for name,spec in entries.items():
        if not isinstance(name,str) or not NAME.fullmatch(name):
            raise ValueError("Server names must use lowercase letters, digits, underscores or hyphens")
        if not isinstance(spec,dict):
            raise ValueError("Server entry must be an object: "+name)
        if not spec.get("enabled",True):
            continue
        if "url" in spec:
            continue  # Hosted entries are emitted to clients; not local children.
        prepare(spec,env)
        local[name]=spec
    if not local:
        raise ValueError("No enabled local backends")
    return local

def private_json(path, value):
    temp=path.with_suffix(path.suffix+".tmp")
    fd=os.open(temp,os.O_WRONLY|os.O_CREAT|os.O_TRUNC,0o600)
    with os.fdopen(fd,"w") as stream:
        json.dump(value,stream,indent=2); stream.write("\n")
    os.replace(temp,path)

def process_table():
    result=subprocess.run(["ps","-axo","pid=,ppid=,pgid=,lstart="],
                          capture_output=True,text=True,check=True)
    table={}
    for line in result.stdout.splitlines():
        fields=line.split(None,3)
        if len(fields)==4:
            table[int(fields[0])]=(int(fields[1]),int(fields[2]),fields[3])
    return table

def descendants(root,table):
    found={root}
    while True:
        children={pid for pid,(parent,_,_) in table.items() if parent in found}
        new=found|children
        if new==found: break
        found=new
    return {pid:table[pid] for pid in found if pid in table}

def cleanup(process, known):
    # Snapshot SDK-created sessions before and during graceful teardown.
    known.update(descendants(process.pid,process_table()))
    if process.poll() is None:
        process.terminate()
        deadline=time.monotonic()+6
        while process.poll() is None and time.monotonic()<deadline:
            known.update(descendants(process.pid,process_table()))
            time.sleep(.1)
        if process.poll() is None: process.kill()
        process.wait(timeout=3)
    for sig in (signal.SIGTERM,signal.SIGKILL):
        table=process_table()
        for pid,identity in known.items():
            current=table.get(pid)
            if current and current[1:]==identity[1:]:
                with suppress(ProcessLookupError): os.killpg(current[1],sig)
        deadline=time.monotonic()+(1 if sig==signal.SIGTERM else 3)
        while time.monotonic()<deadline:
            table=process_table()
            survivors=[pid for pid,identity in known.items()
                       if pid in table and table[pid][1:]==identity[1:]]
            if not survivors: return
            time.sleep(.1)
    raise RuntimeError("Owned child processes survived cleanup")

async def healthy(url, timeout):
    async def check():
        async with streamablehttp_client(url) as streams:
            async with ClientSession(streams[0],streams[1]) as client:
                await client.initialize()
                await client.list_tools()
    try:
        await asyncio.wait_for(check(),timeout)
        return True
    except Exception:
        return False

async def run(args, env):
    args.state_dir.mkdir(parents=True,exist_ok=True,mode=0o700)
    with (args.state_dir/"service.lock").open("a") as lock:
        try: fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
        except BlockingIOError: raise ValueError("Service state directory is already owned")
        # Refuse to monitor someone else's listener if a second service is started on the same port.
        with socket.socket() as listener:
            listener.bind(("127.0.0.1",args.port))
        entries=read_inventory(args.inventory,env)
        config={"mcpServers":{
            name:{"command":sys.executable,"args":[str(ROOT/"launch_backend.py"),str(args.inventory),name]}
            for name in entries}}
        private_json(args.state_dir/"proxy.json",config)
        stop=asyncio.Event()
        loop=asyncio.get_running_loop()
        for sig in (signal.SIGTERM,signal.SIGINT):
            loop.add_signal_handler(sig,stop.set)
        recent=deque()
        generation=0
        status_path=args.state_dir/"service.json"
        async def pause(seconds):
            try: await asyncio.wait_for(stop.wait(),seconds)
            except asyncio.TimeoutError: pass
        while not stop.is_set():
            generation+=1
            process=subprocess.Popen([str(ROOT/".venv/bin/mcp-proxy"),
                "--host","127.0.0.1","--port",str(args.port),"--pass-environment",
                "--named-server-config",str(args.state_dir/"proxy.json")],
                env=env,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,start_new_session=True)
            known={}
            state={"generation":generation,"proxy_pid":process.pid,"state":"starting","servers":list(entries)}
            try:
                private_json(status_path,state)
                LOG.info("starting generation %d",generation)
                deadline=time.monotonic()+args.startup_timeout
                failures=0
                ready=False
                while not stop.is_set():
                    known.update(descendants(process.pid,process_table()))
                    if process.poll() is not None: break
                    checks=await asyncio.gather(*(healthy(
                        f"http://127.0.0.1:{args.port}/servers/{name}/mcp",args.timeout) for name in entries))
                    if all(checks):
                        failures=0
                        ready=True
                        state["state"]="running"
                        state["backend_pids"]=[p for p in known if p!=process.pid]
                        private_json(status_path,state)
                    elif ready:
                        failures+=1
                        LOG.warning("backend discovery failed for %s (%d/%d)", ",".join(name for name,ok in zip(entries,checks) if not ok),failures,args.failures)
                        if failures>=args.failures: break
                    elif time.monotonic()>=deadline:
                        LOG.warning("startup timed out")
                        break
                    # Probe promptly during startup; steady-state polling stays inexpensive.
                    await pause(args.interval if ready else min(1, max(0, deadline-time.monotonic())))
            finally:
                await asyncio.to_thread(cleanup,process,known)
            if stop.is_set(): break
            now=time.monotonic()
            recent.append(now)
            while recent and now-recent[0]>300: recent.popleft()
            if len(recent)>args.max_restarts:
                state["state"]="failed"
                private_json(status_path,state)
                LOG.error("Restart budget exhausted; awaiting manual service restart")
                await stop.wait()
                return
            LOG.warning("restarting shared proxy; interrupted calls are not replayed")
            await pause(min(2**(len(recent)-1),30))
        state["state"]="stopped"
        private_json(status_path,state)

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--inventory",type=Path,required=True)
    parser.add_argument("--state-dir",type=Path,required=True)
    parser.add_argument("--env-file",type=Path)
    parser.add_argument("--port",type=int,default=37373)
    parser.add_argument("--interval",type=float,default=60)
    parser.add_argument("--timeout",type=float,default=8)
    parser.add_argument("--failures",type=int,default=2)
    parser.add_argument("--max-restarts",type=int,default=3)
    parser.add_argument("--startup-timeout",type=float,default=90)
    args=parser.parse_args()
    args.inventory=args.inventory.resolve()
    args.state_dir=args.state_dir.resolve()
    if not (0<args.port<65536 and args.interval>0 and args.timeout>0 and args.startup_timeout>0 and args.failures>0 and args.max_restarts>=0):
        parser.error("Port and timing/restart parameters are invalid")
    env={}
    if args.env_file:
        if not args.env_file.is_file(): parser.error("Environment file does not exist")
        env.update({k:v for k,v in dotenv_values(args.env_file,interpolate=False).items() if v is not None})
    env.update(os.environ)
    logging.basicConfig(level=logging.WARNING,format="%(asctime)s %(levelname)s %(message)s")
    LOG.setLevel(logging.INFO)
    try:
        asyncio.run(run(args,env))
    except (ValueError,KeyError,OSError,RuntimeError) as error:
        LOG.error("%s",str(error) if isinstance(error,(ValueError,RuntimeError)) else type(error).__name__)
        sys.exit(1)
if __name__=="__main__": main()
