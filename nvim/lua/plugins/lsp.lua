return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason.nvim",
    },
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
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = { "nvim-dap-ui" },
    },
  },
}
