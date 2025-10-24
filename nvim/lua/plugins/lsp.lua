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
    -- cond = false,
    event = "InsertEnter",
    opts = {},
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
    build = "'cd' 'lua/fzy' && 'make'",
    opts = {},
  },

}
