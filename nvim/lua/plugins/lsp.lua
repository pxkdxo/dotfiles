return {
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre", -- Load lspconfig when a buffer is read
    config = function()
      -- Add configurations for other LSP servers as needed
      -- Example: Configure a specific LSP server
      -- require("lspconfig").lua_ls.setup {
      --   settings = {
      --     Lua = {
      --       runtime = {
      --         version = "LuaJIT",
      --       },
      --       diagnostics = {
      --         globals = { "vim" },
      --       },
      --     },
      --   },
      -- }
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        }
      }
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ---@type boolean | string[] | { exclude: string[] }
      automatic_enable = true,
    },
    dependencies = {
      {"mason-org/mason.nvim"},
      "neovim/nvim-lspconfig",
    },
  }
}
