return {
  {
    "olimorris/codecompanion.nvim",
    cond = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    cmd = "Copilot",
    opts = {
      panel = { enabled = false },
      suggestion = {
        enabled = true,
        auto_refresh = true,
        hide_during_completion = false,
        debounce = 100,
        trigger_on_accept = true,
        keymap = {
          accept = "<M-l>",
          accept_word = "<M-w>",
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<M-g>",
        },
      },
      copilot_node_command = 'node', -- Node.js version must be > 20
      workspace_folders = {},
    },
  },
  {
    "yetone/avante.nvim",
    cond = vim.g.vscode == nil and vim.fn.executable("make") == 1,
    build = "make",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      -- "nvim-mini/mini.pick", -- for file_selector provider mini.pick
      -- "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "folke/snacks.nvim", -- for input provider snacks
      -- "stevearc/dressing.nvim", -- for input provider dressing
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
    },
    keys = {
      {
        "<leader>a+",
        function()
          local tree_ext = require("avante.extensions.nvim_tree")
          tree_ext.add_file()
        end,
        desc = "Select file in NvimTree",
        ft = "NvimTree",
      },
      {
        "<leader>a-",
        function()
          local tree_ext = require("avante.extensions.nvim_tree")
          tree_ext.remove_file()
        end,
        desc = "Deselect file in NvimTree",
        ft = "NvimTree",
      },
    },
    opts = {
      provider = (vim.env.GEMINI_API_KEY or vim.env.AVANTE_GEMINI_API_KEY) and "gemini" or "copilot",
      providers = {
        gemini = { model = "gemini-2.5-flash" },
      },
      auto_suggestions_provider = nil,
      behaviour = {
        auto_suggestions = false, -- Experimental stage
      },
      selector = {
        provider = "fzf_lua",
        provider_opts = {},
        exclude_auto_select = { "NvimTree" },
      },
      input = {
        provider = "snacks",
        provider_opts = {
          title = "* Avante Input *",
          icon = "",
        },
      },
      windows = {
        sk = {
          floating = true, -- Open the 'AvanteAsk' prompt in a floating window
        },
      },
    },
  },
}
