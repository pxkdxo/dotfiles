return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    cond = false,
    opts = {},
  },
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    cmd = "Copilot",
    opts = {
      panel = {
        enabled = true,
        auto_refresh = true,
        keymap = {
          jump_prev = "[[",
          jump_next = "]]",
          accept = "<CR>",
          refresh = "<M-r>",
          open = "<M-CR>"
        },
        layout = {
          position = "bottom", -- | top | left | right | bottom |
          ratio = 0.4
        },
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = true,
        debounce = 75,
        trigger_on_accept = true,
        keymap = {
          accept = "<M-Space>",
          accept_word = false,
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<M-q>",
        },
      },
      copilot_node_command = 'node', -- Node.js version must be > 20
      workspace_folders = {},
    },
  },
  {
    "yetone/avante.nvim",
    build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" or "make",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "folke/snacks.nvim", -- for input provider snacks
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
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
      provider = "copilot",
      auto_suggestions_provider = "gemini",
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
    },
  },
}
