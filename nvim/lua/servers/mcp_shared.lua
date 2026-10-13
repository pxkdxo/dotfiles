-- Shared MCP wiring for the existing Neovim AI plugins.
local M = {}
local root = vim.fn.stdpath("config") .. "/../mcp-shared"
local client_dir = root .. "/client"
local resolved

function M.connections()
  if resolved then return vim.deepcopy(resolved) end
  local command = {
    root .. "/.venv/bin/python", root .. "/connections.py",
    "--connections", vim.fn.expand("~/.config/mcp-shared/connections.json"),
    "--env-file", vim.fn.expand("~/.env"),
  }
  local result = vim.system(command, { text = true }):wait(10000)
  assert(result and result.code == 0, "Shared MCP connection resolution failed")
  resolved = vim.json.decode(result.stdout)
  return vim.deepcopy(resolved)
end

local function local_servers()
  local servers = {}
  for _, entry in ipairs(M.connections()) do
    if entry.url:match("^http://127%.0%.0%.1:") then
      servers[entry.name] = { url = entry.url }
    end
  end
  return servers
end

local function refresh_adapters()
  vim.schedule(function()
    if package.loaded["avante.config"] then
      require("mcp-client.adapters.avante").refresh()
    end
    if package.loaded["codecompanion.config"] then
      require("mcp-client.adapters.codecompanion").exports.refresh()
    end
  end)
end

function M.transform(specs)
  if vim.g.vscode then return specs end
  if vim.fn.executable(root .. "/.venv/bin/python") == 0
      or vim.fn.filereadable(root .. "/connections.json") == 0 then
    vim.schedule(function() vim.notify("Shared MCP: run ~/.local/etc/setup-mcp.sh", vim.log.levels.WARN) end)
    return specs
  end
  local ok, endpoints = pcall(M.connections)
  if not ok then
    vim.schedule(function() vim.notify("Shared MCP credentials unavailable; check ~/.env", vim.log.levels.WARN) end)
    return specs
  end
  local result = {{
    dir = client_dir,
    name = "mcp-client.nvim",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = function()
      local orchestrator = require("mcp-client.native_legacy").convert(require("servers.orchestrator"))
      return {
        servers = local_servers(),
        native_servers = { orchestrator = orchestrator },
      }
    end,
    config = function(_, opts)
      require("mcp-client").setup(opts)
      vim.api.nvim_create_autocmd("User", {
        pattern = { "MCPAttach", "MCPDetach" },
        callback = refresh_adapters,
      })
    end,
  }}
  for _, spec in ipairs(specs) do
    if spec[1] == "yetone/avante.nvim" then
        table.insert(spec.dependencies, "mcp-client.nvim")
        spec.opts.acp_providers["claude-code"].mcp_servers = vim.deepcopy(endpoints)
        spec.opts.acp_providers["cursor-agent"].mcp_servers = vim.deepcopy(endpoints)
        spec.opts.custom_tools = function() return require("mcp-client.adapters.avante").custom_tools() end
    elseif spec[1] == "olimorris/codecompanion.nvim" then
        table.insert(spec.dependencies, "mcp-client.nvim")
        local original = spec.opts.adapters.acp.claude_code
        spec.opts.adapters.acp.claude_code = function()
          local configured = original()
          configured.defaults = configured.defaults or {}
          configured.defaults.mcpServers = vim.deepcopy(endpoints)
          return configured
        end
        spec.opts.extensions["mcp-client"] = {
          callback = "mcp-client.adapters.codecompanion",
        }
    end
    table.insert(result, spec)
  end
  return result
end

return M
