"""Install shared MCP connections and a platform service, preserving unrelated config."""
import argparse
import json
import os
from pathlib import Path
import platform
import plistlib
import re
import shutil
import subprocess
import sys
import time
import tomllib
from dotenv import dotenv_values
from generate import generate
from launch_backend import expand
from service import read_inventory

ROOT = Path(__file__).resolve().parent
LABEL = 'com.patrickdeyoreo.mcp-shared'

def merge_codex(source, generated, names):
    # Parse first, so malformed existing configuration is never replaced.
    previous = tomllib.loads(source)
    remove = set(names) | {'mcphub', 'sequential-thinking'}
    kept, skip = [], False
    for line in source.splitlines(keepends=True):
        if line.lstrip().startswith('['):
            match = re.match(r'^\s*\[mcp_servers\.([\w-]+)(?:\.[^\]]+)?\]\s*(?:#.*)?$', line.strip())
            skip = bool(match and match[1] in remove)
        if not skip:
            kept.append(line)
    result = ''.join(kept).rstrip() + '\n\n' + generated
    parsed = tomllib.loads(result)
    assert set(parsed['mcp_servers']) == (set(previous.get('mcp_servers', {})) - remove) | set(tomllib.loads(generated)['mcp_servers'])
    return result

def write(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists() and path.read_bytes() == data:
        return
    if path.exists():
        backup = path.with_name(path.name + '.pre-mcp-' + str(time.time_ns()))
        shutil.copy2(path, backup)
        backup.chmod(0o600)
    temp = path.with_name(path.name + '.tmp')
    temp.write_bytes(data)
    temp.chmod(0o600)
    temp.replace(path)

def service_path(home):
    parts = [home/'.local/share/homebrew/bin', home/'.local/share/homebrew/sbin', home/'.local/bin', Path('/opt/homebrew/bin'), Path('/opt/homebrew/sbin'), Path('/home/linuxbrew/.linuxbrew/bin'), Path('/home/linuxbrew/.linuxbrew/sbin'), home/'.linuxbrew/bin', Path('/usr/local/bin'), Path('/usr/bin'), Path('/bin'), Path('/usr/sbin'), Path('/sbin')]
    return ':'.join(map(str, parts))

def install(home, system, prepare_only=False):
    envfile = home/'.env'
    inventory = ROOT/'servers.json'
    data = json.loads(inventory.read_text())['mcpServers']
    if not prepare_only:
        if not envfile.is_file():
            raise ValueError('Restore ~/.env before MCP setup')
        env = {k:v for k,v in dotenv_values(envfile, interpolate=False).items() if v is not None}
        env.update(os.environ)
        env['PATH'] = service_path(home)
        entries = read_inventory(inventory, env)
        for name,spec in entries.items():
            command = expand(spec['command'], env)
            if not shutil.which(command, path=env['PATH']):
                raise ValueError('Missing backend command: ' + command)
        for spec in data.values():
            if spec.get('enabled', True) and 'url' in spec:
                for value in spec.get('headers', {}).values():
                    from string import Template
                    if any(not env.get(k) for k in Template(value).get_identifiers()):
                        raise ValueError('Missing hosted credential variable')
    output = home/'.config/mcp-shared'
    generate(inventory, output, 37373)
    codex = home/'.codex/config.toml'
    candidate = merge_codex(codex.read_text() if codex.exists() else '', (output/'codex-mcp.toml').read_text(), data)
    cursor = home/'.cursor/mcp.json'
    cursor_data = json.loads(cursor.read_text()) if cursor.exists() else {}
    entries = cursor_data.setdefault('mcpServers', {})
    for name in set(data) | {'mcphub', 'sequential-thinking'}:
        entries.pop(name, None)
    for name,spec in json.loads((output/'connections.json').read_text())['mcpServers'].items():
        entries[name] = {k:v for k,v in spec.items() if k != 'type'}
    claude = Path(os.environ['CLAUDE_CONFIG_DIR'])/'.claude.json' if os.environ.get('CLAUDE_CONFIG_DIR') and not prepare_only else home/'.claude.json'
    claude_data = json.loads(claude.read_text()) if claude.exists() else {}
    managed = set(data) | {'mcphub', 'sequential-thinking'}
    claude_entries = claude_data.setdefault('mcpServers', {})
    for name in managed:
        claude_entries.pop(name, None)
    # Local scope wins over user scope. Remove only our managed overrides,
    # preserving project settings, trust choices and unrelated servers.
    for project in claude_data.get('projects', {}).values():
        for name in managed:
            project.get('mcpServers', {}).pop(name, None)
    generated_codex = tomllib.loads((output/'codex-mcp.toml').read_text())['mcp_servers']
    for name,spec in json.loads((output/'connections.json').read_text())['mcpServers'].items():
        entry = {'type':'http', 'url':spec['url']}
        if spec.get('headers'):
            entry['headersHelper'] = generated_codex[name]['http_headers_helper']
        claude_entries[name] = entry
    # Compute and validate all merges before replacing any client file.
    write(codex, candidate.encode())
    write(cursor, (json.dumps(cursor_data, indent=2)+'\n').encode())
    write(claude, (json.dumps(claude_data, indent=2)+'\n').encode())
    args = [str(ROOT/'.venv/bin/python'), str(ROOT/'service.py'), '--inventory', str(inventory), '--state-dir', str(home/'.local/state/mcp-shared'), '--env-file', str(envfile), '--port', '37373']
    if system == 'Darwin':
        (home/'Library/Logs').mkdir(parents=True, exist_ok=True)
        plist = {'Label':LABEL, 'ProgramArguments':args, 'RunAtLoad':True, 'KeepAlive':False, 'ExitTimeOut':45, 'WorkingDirectory':str(home), 'EnvironmentVariables':{'PATH':service_path(home)}, 'StandardOutPath':str(home/'Library/Logs/mcp-shared.out.log'), 'StandardErrorPath':str(home/'Library/Logs/mcp-shared.err.log'), 'ProcessType':'Background'}
        target = home/'Library/LaunchAgents'/f'{LABEL}.plist'
        write(target, plistlib.dumps(plist))
        if not prepare_only:
            domain = f'gui/{os.getuid()}'
            subprocess.run(['launchctl','bootout',domain+'/com.patrickdeyoreo.mcphub'], capture_output=True)
            old = target.with_name('com.patrickdeyoreo.mcphub.plist')
            if old.exists(): old.rename(old.with_suffix('.plist.disabled'))
            subprocess.run(['launchctl','bootout',domain+'/'+LABEL], capture_output=True)
            # bootout can return before launchd has finished unregistering the job.
            for attempt in range(30):
                loaded = subprocess.run(['launchctl','bootstrap',domain,str(target)], capture_output=True)
                if loaded.returncode == 0:
                    break
                time.sleep(.5)
            else:
                raise ValueError('launchd bootstrap failed; inspect launchctl and service logs')
    elif system == 'Linux':
        # %h is resolved by systemd; quote executable paths for homes with spaces.
        unit = '''[Unit]
Description=Shared MCP proxy and supervised backends

[Service]
Type=simple
ExecStart="%h/.local/etc/mcp-shared/.venv/bin/python" "%h/.local/etc/mcp-shared/service.py" --inventory "%h/.local/etc/mcp-shared/servers.json" --state-dir "%h/.local/state/mcp-shared" --env-file "%h/.env" --port 37373
WorkingDirectory=%h
Restart=no
KillMode=control-group
TimeoutStopSec=45
Environment="PATH=REPLACE_PATH"
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
'''.replace('REPLACE_PATH', service_path(home).replace(str(home),'%h'))
        target = home/'.config/systemd/user/mcp-shared.service'
        write(target, unit.encode())
        if not prepare_only:
            subprocess.run(['systemctl','--user','stop','mcphub.service'], capture_output=True)
            subprocess.run(['systemctl','--user','disable','mcphub.service'], capture_output=True)
            subprocess.run(['systemctl','--user','daemon-reload'], check=True)
            subprocess.run(['systemctl','--user','enable','mcp-shared.service'], check=True)
            subprocess.run(['systemctl','--user','restart','mcp-shared.service'], check=True)
    else:
        raise ValueError('Supported service managers: macOS launchd and Linux systemd')
    print('Prepared' if prepare_only else 'Installed', len(json.loads((output/'connections.json').read_text())['mcpServers']), 'MCP connections and', system, 'service')

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--prepare-only', action='store_true', help='Write configuration without credential checks or service activation')
    p.add_argument('--home', type=Path, default=Path.home())
    p.add_argument('--platform', choices=['Darwin','Linux'], default=platform.system())
    a = p.parse_args()
    if not a.prepare_only and (a.home.resolve()!=Path.home().resolve() or a.platform!=platform.system()):
        p.error('Alternate home/platform requires --prepare-only')
    os.environ['HOME'] = str(a.home.resolve())
    install(a.home.resolve(), a.platform, a.prepare_only)

if __name__ == '__main__':
    try: main()
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        print('MCP setup failed: '+str(error), file=sys.stderr)
        sys.exit(2)
