return {
  {
    'akinsho/git-conflict.nvim',
    version = "*",
    config = true,
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {},
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
      "sindrets/diffview.nvim",        -- optional - Diff integration

      -- Only one of these is needed.
      "ibhagwan/fzf-lua",              -- optional
      --"nvim-mini/mini.pick",         -- optional
      --"folke/snacks.nvim",           -- optional
    },
    opts = {
      graph_style = "unicode",
      highlight = {
        italic = true,
        bold = true,
        underline = true
      },
      -- Disabling `auto_refresh` will make it so you have to manually refresh the status after you open it.
      auto_refresh = true,
      -- Change the default way of opening neogit
      kind = "tab",
      -- Floating window style 
      floating = {
        relative = "editor",
        width = 0.85,
        height = 0.70,
        style = "minimal",
        border = "rounded",
      },
      -- Disable line numbers
      disable_line_numbers = true,
      -- Disable relative line numbers
      disable_relative_line_numbers = true,
      -- The time after which an output console is shown for slow running commands
      console_timeout = 2500,
      -- Automatically show console if a command takes more than console_timeout milliseconds
      auto_show_console = true,
      -- Automatically close the console if the process exits with a 0 (success) status
      auto_close_console = true,
    },
  },
}
