"""Fresh-home config generation for both service managers; never starts real services."""
import importlib
import json
import os
from pathlib import Path
import plistlib
import tempfile
import tomllib
import unittest
from unittest.mock import patch
import setup

generator = importlib.import_module('generate')

class SetupTests(unittest.TestCase):
    def test_fresh_homes_and_idempotency(self):
        for system in ('Linux','Darwin'):
            with self.subTest(system=system), tempfile.TemporaryDirectory() as temp:
                home = Path(temp)/'Different User'
                root = home/'.local/etc/mcp-shared'
                root.mkdir(parents=True)
                (home/'.config').symlink_to('.local/etc')
                (root/'servers.json').write_bytes((setup.ROOT/'servers.json').read_bytes())
                codex = home/'.codex/config.toml'
                codex.parent.mkdir()
                codex.write_text('model = "test"\n[mcp_servers.extra]\ncommand="extra"\n[mcp_servers.mcphub]\nurl="http://old"\n')
                cursor = home/'.cursor/mcp.json'
                cursor.parent.mkdir()
                cursor.write_text(json.dumps({'other':42,'mcpServers':{'extra':{'command':'extra'},'mcphub':{'url':'old'}}}))
                claude = home/'.claude.json'
                claude.write_text(json.dumps({'keep':'value','mcpServers':{'mcphub':{'url':'old'},'extra':{'command':'extra'}},'projects':{'example':{'mcpServers':{'mcphub':{},'time':{},'project_extra':{}},'hasTrustDialogAccepted':False}}}))
                with patch.object(setup,'ROOT',root), patch.object(generator,'ROOT',root), patch('sys.executable',str(root/'.venv/bin/python')), patch.dict(os.environ,{'HOME':str(home)}):
                    setup.install(home,system,True)
                    first = codex.read_bytes(),cursor.read_bytes(),claude.read_bytes()
                    setup.install(home,system,True)
                    self.assertEqual(first,(codex.read_bytes(),cursor.read_bytes(),claude.read_bytes()))
                parsed=tomllib.loads(codex.read_text())
                self.assertEqual(len(parsed['mcp_servers']),14)
                self.assertEqual(parsed['model'],'test')
                self.assertNotIn('mcphub',parsed['mcp_servers'])
                self.assertEqual(json.loads(cursor.read_text())['other'],42)
                cc=json.loads(claude.read_text())
                self.assertEqual(len(cc['mcpServers']),14)
                self.assertEqual(cc['keep'],'value')
                self.assertEqual(set(cc['projects']['example']['mcpServers']),{'project_extra'})
                self.assertFalse(cc['projects']['example']['hasTrustDialogAccepted'])
                self.assertIn('headersHelper',cc['mcpServers']['github'])
                self.assertNotIn('headers',cc['mcpServers']['github'])
                for p in [codex,cursor,claude,root/'proxy.json',root/'connections.json',root/'codex-mcp.toml']:
                    self.assertNotIn('/Users/patrick.deyoreo',p.read_text())
                    self.assertNotIn('Documents/Code',p.read_text())
                if system=='Darwin':
                    plist=plistlib.loads((home/'Library/LaunchAgents'/f'{setup.LABEL}.plist').read_bytes())
                    self.assertFalse(plist['KeepAlive'])
                    self.assertEqual(plist['ProgramArguments'][0],str(root/'.venv/bin/python'))
                else:
                    unit=(home/'.config/systemd/user/mcp-shared.service').read_text()
                    self.assertIn('KillMode=control-group',unit)
                    self.assertIn('Restart=no',unit)
                    self.assertIn('"%h/.local/etc/mcp-shared/.venv/bin/python"',unit)
                    self.assertNotIn('/Users/',unit)

    def test_invalid_config_preserved(self):
        with self.assertRaises(tomllib.TOMLDecodeError):
            setup.merge_codex('invalid=[', '[mcp_servers.time]\nurl="http://localhost"', ['time'])

if __name__=='__main__': unittest.main()
