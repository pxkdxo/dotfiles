return {
  {
    "folke/persistence.nvim",
    cond = vim.g.vscode == nil,
    event = "BufReadPre",
    opts = {},
    -- stylua: ignore
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>qS", function() require("persistence").select() end,desc = "Select Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
  },
  {
    "nvim-neorg/neorg",
    cond = vim.g.vscode == nil,
    version = "*", -- Pin Neorg to the latest stable release
    ft = "norg", -- lazy-load on filetype
    opts = { load = { ["core.defaults"] = {} } },
  },
}
