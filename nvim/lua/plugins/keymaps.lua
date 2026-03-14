return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      spec = {
        { "<leader>a",  group = "ai" },
        { "<leader>c",  group = "comment" },
        { "<leader>d",  group = "debug" },
        { "<leader>e",  group = "env" },
        { "<leader>g",  group = "git" },
        { "<leader>l",  group = "lsp" },
        { "<leader>m",  group = "explorer" },
        { "<leader>n",  desc = "notifications" },
        { "<leader>p",  desc = "yank history" },
        { "<leader>q",  group = "session" },
        { "<leader>s",  group = "search" },
        { "<leader>x",  group = "diagnostics" },
        { "<leader>z",  desc = "zen mode" },
        { "<leader>`",  group = "terminal" },
        { "<leader>w",  group = "windows" },
        { "<leader>b",  group = "buffers" },
        { "g",          group = "goto" },
        { "[",          group = "prev" },
        { "]",          group = "next" },
        { "<Space>",    group = "treesj" },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps",
      },
    },
  },
}
