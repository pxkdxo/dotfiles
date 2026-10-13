"""Local-only acceptance tests for service.py; no model calls or real credentials.

Run: .venv/bin/python test_service.py
Uses ephemeral ports, temporary inventories/state, and only synthetic probe backends.
"""
import asyncio
import json
import os
from pathlib import Path
import signal
import socket
import subprocess
import sys
import tempfile
import time
import unittest

import httpx
from mcp import ClientSession
from mcp.client.streamable_http import streamablehttp_client

ROOT = Path(__file__).resolve().parent


def unused_port():
    with socket.socket() as sock:
        sock.bind(("127.0.0.1", 0))
        return sock.getsockname()[1]


def alive(pid):
    result = subprocess.run(["ps", "-o", "stat=", "-p", str(pid)],
                            capture_output=True, text=True)
    return result.returncode == 0 and bool(result.stdout.strip()) and not result.stdout.strip().startswith("Z")


async def wait_for(predicate, timeout=15, message="condition timed out"):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if predicate():
            return
        await asyncio.sleep(.1)
    raise AssertionError(message)


async def inspect(port, marker="service-acceptance"):
    url = f"http://127.0.0.1:{port}/servers/probe/mcp"
    async with streamablehttp_client(url) as streams:
        async with ClientSession(streams[0], streams[1]) as session:
            await session.initialize()
            result = await session.call_tool("inspect_backend", {"marker": marker})
            if result.isError:
                raise AssertionError("probe returned tool error")
            payload = result.structuredContent or json.loads(result.content[0].text)
            assert payload["marker"] == marker
            assert payload["secret_ok"]
            return payload["pid"]


class ServiceCase(unittest.IsolatedAsyncioTestCase):
    async def asyncSetUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix="mcp-service-test-")
        self.directory = Path(self.tmp.name)
        self.port = unused_port()
        self.known_backends = set()
        self.process = None
        self.env = dict(os.environ, POC_ROOT=str(ROOT), POC_PYTHON=sys.executable,
                        POC_SECRET="synthetic-$literal-keep")
        self.inventory = self.directory / "inventory.json"
        original = json.loads((ROOT / "inventory.json").read_text())
        self.inventory.write_text(json.dumps({"mcpServers": {"probe": original["mcpServers"]["probe"]}}))
        self.log_path = self.directory / "runner.log"
        self.log = self.log_path.open("w")

    def start(self, extra=()):
        self.process = subprocess.Popen([
            sys.executable, str(ROOT / "service.py"),
            "--inventory", str(self.inventory), "--state-dir", str(self.directory / "state"),
            "--port", str(self.port), "--interval", ".5", "--timeout", "2",
            "--failures", "2", "--max-restarts", "3", *extra],
            env=self.env, stdout=self.log, stderr=subprocess.STDOUT, start_new_session=True)

    async def ready(self, previous=None, timeout=20):
        deadline = time.monotonic() + timeout
        last_error = None
        while time.monotonic() < deadline:
            if self.process.poll() is not None:
                self.fail(f"service exited before readiness (exit {self.process.returncode})")
            try:
                pid = await asyncio.wait_for(inspect(self.port), 3)
                self.known_backends.add(pid)
                status_path = self.directory / "state" / "service.json"
                status = json.loads(status_path.read_text()) if status_path.exists() else {}
                if (previous is None or pid != previous) and status.get("state") == "running":
                    return pid
            except (Exception, BaseExceptionGroup) as error:
                last_error = type(error).__name__
            await asyncio.sleep(.15)
        self.fail(f"backend did not become ready; last error={last_error}")

    async def assert_no_listener(self):
        async with httpx.AsyncClient(timeout=1) as client:
            try:
                await client.get(f"http://127.0.0.1:{self.port}/status")
            except httpx.HTTPError:
                return
        self.fail("service port still accepts HTTP requests")

    async def asyncTearDown(self):
        try:
            if self.process is not None:
                # Kill only the process group created by this test, including known
                # descendants if the runner created a separate group for its proxy.
                try:
                    os.killpg(self.process.pid, signal.SIGTERM)
                except ProcessLookupError:
                    pass
                for pid in self.known_backends:
                    if alive(pid):
                        os.kill(pid, signal.SIGTERM)
                try:
                    await asyncio.to_thread(self.process.wait, timeout=5)
                except subprocess.TimeoutExpired:
                    os.killpg(self.process.pid, signal.SIGKILL)
                    await asyncio.to_thread(self.process.wait)
                for pid in self.known_backends:
                    if alive(pid):
                        os.kill(pid, signal.SIGKILL)
            self.log.close()
            # Check every artifact produced in this synthetic test, not just logs.
            for path in self.directory.rglob("*"):
                if path.is_file():
                    self.assertNotIn(self.env.get("POC_SECRET", "synthetic-$literal-keep").encode(),
                                     path.read_bytes(), f"secret persisted in {path.name}")
        finally:
            self.tmp.cleanup()

    async def test_backend_death_recovers_and_sigterm_cleans_children(self):
        self.start()
        original = await self.ready()
        os.kill(original, signal.SIGKILL)
        replacement = await self.ready(previous=original)
        self.assertNotEqual(original, replacement)
        self.assertFalse(alive(original))
        self.process.send_signal(signal.SIGTERM)
        await wait_for(lambda: self.process.poll() is not None, message="SIGTERM did not stop service")
        await wait_for(lambda: not alive(replacement), message="backend orphaned after SIGTERM")
        await self.assert_no_listener()

    async def test_missing_variable_fails_before_listener(self):
        data = json.loads(self.inventory.read_text())
        data["mcpServers"]["probe"]["env"]["PROBE_SECRET"] = "${MCP_ACCEPTANCE_UNDEFINED_SECRET}"
        self.inventory.write_text(json.dumps(data))
        self.env.pop("MCP_ACCEPTANCE_UNDEFINED_SECRET", None)
        self.start()
        await wait_for(lambda: self.process.poll() is not None, timeout=10,
                       message="missing-variable startup did not fail promptly")
        self.assertNotEqual(self.process.returncode, 0)
        await self.assert_no_listener()
        self.assertIn("MCP_ACCEPTANCE_UNDEFINED_SECRET", self.log_path.read_text())

    async def test_repeated_backend_failure_exhausts_restart_budget(self):
        self.start()
        pid = await self.ready()
        for failure in range(4):
            os.kill(pid, signal.SIGKILL)
            if failure < 3:
                pid = await self.ready(previous=pid, timeout=25)
            else:
                await self.wait_failed()
        self.assertTrue(all(not alive(pid) for pid in self.known_backends))
        await self.assert_no_listener()
        self.assertIsNone(self.process.poll(), "runner must stay alive so launchd cannot reset its budget")
        state_path = self.directory / "state" / "service.json"
        generation = json.loads(state_path.read_text())["generation"]
        await asyncio.sleep(3)
        self.assertEqual(json.loads(state_path.read_text())["generation"], generation)

    async def wait_failed(self, timeout=25):
        path = self.directory / "state" / "service.json"
        await wait_for(lambda: path.exists() and json.loads(path.read_text()).get("state") == "failed",
                       timeout=timeout, message="service ignored restart budget")

    async def test_startup_hang_is_bounded_and_child_is_cleaned(self):
        pid_file = self.directory / "hanging.pid"
        code = "import os,time; from pathlib import Path; Path(" + repr(str(pid_file)) + ").write_text(str(os.getpid())); time.sleep(60)"
        self.inventory.write_text(json.dumps({"mcpServers": {"probe": {
            "command": sys.executable, "args": ["-c", code], "env": {}}}}))
        self.start(("--startup-timeout", "2", "--max-restarts", "0"))
        await wait_for(pid_file.exists, timeout=8, message="hanging backend never started")
        pid = int(pid_file.read_text())
        self.known_backends.add(pid)
        await self.wait_failed(timeout=15)
        await wait_for(lambda: not alive(pid), message="startup timeout left backend running")
        await self.assert_no_listener()


if __name__ == "__main__":
    unittest.main(verbosity=2)
