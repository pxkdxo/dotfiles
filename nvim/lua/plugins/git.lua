return {
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
    cond = not vim.g.vscode,
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
        width = 0.8,
        height = 0.7,
        style = "minimal",
        border = "rounded",
      },
      -- Disable line numbers
      disable_line_numbers = true,
      -- Disable relative line numbers
      disable_relative_line_numbers = true,
      -- The time after which an output console is shown for slow running commands
      console_timeout = 2000,
      -- Automatically show console if a command takes more than console_timeout milliseconds
      auto_show_console = true,
      -- Automatically close the console if the process exits with a 0 (success) status
      auto_close_console = true,
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    cond = not vim.g.vscode,
    opts = {},
  },
  {
    'pwntester/octo.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'ibhagwan/fzf-lua',
      -- OR 'folke/snacks.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    cond = not vim.g.vscode,
    opts = {
      picker = "fzf-lua", -- or "fzf-lua" or "snacks"
    },
  },
}
