"""Deterministic read-only backend for process sharing, correlation and secret tests."""
import asyncio
import os
import json
import sys
from mcp.server.fastmcp import FastMCP
from mcp.types import ToolAnnotations

app = FastMCP("shared-poc-probe")

@app.tool(annotations=ToolAnnotations(readOnlyHint=True, destructiveHint=False, idempotentHint=True, openWorldHint=False))
async def inspect_backend(marker: str, delay_ms: int = 0) -> dict:
    """Return process identity and marker; verify a secret without returning it."""
    print(json.dumps({"poc_call": marker, "pid": os.getpid()}), file=sys.stderr, flush=True)
    await asyncio.sleep(min(max(delay_ms, 0), 2000) / 1000)
    return {"pid": os.getpid(), "marker": marker,
            "secret_ok": os.environ.get("PROBE_SECRET") == "synthetic-$literal-keep",
            "unrelated_secret_absent": "UNRELATED_SECRET" not in os.environ}

@app.resource("poc://identity")
def identity() -> str:
    return str(os.getpid())

@app.prompt()
def explain_probe() -> str:
    return "Use inspect_backend to check the identity of this shared process."

if __name__ == "__main__":
    app.run(transport="stdio")
