return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      automatic_enable = true,
    },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = { library = { "nvim-dap-ui" } },
  },
  {
    "ray-x/lsp_signature.nvim",
    event = "InsertEnter",
    opts = {
      hint_prefix = {
        above = "↙ ",  -- when the hint is on the line above the current line
        current = "← ",  -- when the hint is on the same line
        below = "↖ "  -- when the hint is on the line below the current line
      },
    },
  },
  {
    "ray-x/navigator.lua",
    dependencies = {
      'ray-x/guihua.lua',
      'neovim/nvim-lspconfig',
    },
  },
  {
    'ray-x/guihua.lua',
    cond = vim.g.vscode == nil and vim.fn.executable("make") == 1,
    build = "make -C lua/fzy",
    opts = {},
  },
}
