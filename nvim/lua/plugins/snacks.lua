return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      input = { enabled = true },
      bigfile = { enabled = true },
      statuscolumn = { enabled = true },
    },
  },
}
