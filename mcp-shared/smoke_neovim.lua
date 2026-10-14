local plugin = vim.fn.stdpath("data") .. "/lazy/mcp-client.nvim"
vim.opt.runtimepath:append(plugin)
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/lazy/plenary.nvim")
local client = require("mcp-client.client")
assert(debug.getinfo(client.connect, "S").source:find("/lazy/mcp%-client%.nvim/"), "client not loaded from lazy.nvim install")
local connected
client.connect({ url = "http://127.0.0.1:37373/servers/time/mcp", name = "time" }, {
  on_connect = function(c, err) connected = { c = c, err = err } end,
})
assert(vim.wait(20000, function() return connected ~= nil end, 10), "connect timed out")
assert(not connected.err, tostring(connected.err))
local listed
connected.c:request({ jsonrpc = "2.0", id = 101, method = "tools/list", params = vim.empty_dict() },
  function(err, value) listed = { err = err, value = value } end)
assert(vim.wait(20000, function() return listed ~= nil end, 10), "list timed out")
assert(not listed.err, tostring(listed.err))
local tools = (listed.value.result or listed.value).tools
assert(type(tools) == "table" and #tools >= 2, "time tools missing")
local called
connected.c:request({ jsonrpc = "2.0", id = 102, method = "tools/call",
  params = { name = "get_current_time", arguments = { timezone = "America/Los_Angeles" } } },
  function(err, value) called = { err = err, value = value } end)
assert(vim.wait(20000, function() return called ~= nil end, 10), "call timed out")
assert(not called.err, tostring(called.err))
local payload = called.value.result or called.value
assert(not payload.isError and payload.content and #payload.content > 0, "time call failed")
connected.c:disconnect()
print("Production Neovim MCP time tool PASS")
