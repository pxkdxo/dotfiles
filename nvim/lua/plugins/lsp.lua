return {
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre", -- Load lspconfig when a buffer is read
  },
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
    'nvimdev/lspsaga.nvim',
    event = 'LspAttach',
    dependencies = {
      'nvim-treesitter/nvim-treesitter', -- optional
      'nvim-tree/nvim-web-devicons',     -- optional
    },
    opts = {
      ui = {
        border = 'rounded',
        code_action = '',
      }
    },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = { library = { "nvim-dap-ui" } },
  },
  {
    "ray-x/lsp_signature.nvim",
    cond = false,
    event = "InsertEnter",
    opts = {},
  }
}
