import json
import subprocess
import sys
from pathlib import Path
import tempfile
import unittest
from generate import generate
class ConfigTests(unittest.TestCase):
    def test_local_and_hosted_outputs_keep_templates(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory)
            inventory=root/"servers.json"
            inventory.write_text(json.dumps({"mcpServers":{
                "local":{"command":"example","env":{"KEY":"${PRIVATE_TOKEN}"}},
                "hosted":{"url":"https://example.com/mcp","headers":{"Authorization":"Bearer ${PRIVATE_TOKEN}"}},
                "disabled":{"command":"example","enabled":False}}}))
            self.assertEqual(generate(inventory,root/"out",37474),(1,1))
            proxy=json.loads((root/"out/proxy.json").read_text())
            self.assertNotIn("disabled",proxy["mcpServers"])
            self.assertNotIn("PRIVATE_TOKEN",(root/"out/proxy.json").read_text())
            connections=json.loads((root/"out/connections.json").read_text())
            self.assertEqual(connections["mcpServers"]["hosted"]["headers"]["Authorization"],"Bearer ${PRIVATE_TOKEN}")
            self.assertIn("http_headers_helper = ",(root/"out/codex-mcp.toml").read_text())
            env_file=root/"env"
            env_file.write_text("PRIVATE_TOKEN=synthetic-secret\n")
            helper=subprocess.run([sys.executable,str(Path(__file__).parent/"codex_headers.py"),
                "--connections",str(root/"out/connections.json"),"--env-file",str(env_file),
                "--server","hosted"],capture_output=True,text=True,env={"PATH":"/usr/bin:/bin"})
            self.assertEqual(helper.returncode,0,helper.stderr)
            self.assertEqual(json.loads(helper.stdout),{"Authorization":"Bearer synthetic-secret"})
            env_file.write_text("PRIVATE_TOKEN=\n")
            empty=subprocess.run([sys.executable,str(Path(__file__).parent/"codex_headers.py"),
                "--connections",str(root/"out/connections.json"),"--env-file",str(env_file),
                "--server","hosted"],capture_output=True,text=True,env={"PATH":"/usr/bin:/bin"})
            self.assertEqual(empty.returncode,2)
            self.assertEqual(empty.stdout,"")
    def test_untranslatable_header_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory)
            p=root/"servers.json"
            p.write_text(json.dumps({"mcpServers":{"hosted":{"url":"https://example.com/mcp","headers":{"X-Key":"literal-secret"}}}}))
            with self.assertRaises(ValueError): generate(p,root/"out",37474)
if __name__=="__main__": unittest.main()
