return {
  -- {
  --   "olimorris/codecompanion.nvim",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --   },
  --   cond = not vim.g.vscode,
  --   opts = {},
  -- },
  {
    "zbirenbaum/copilot.lua",
    cond = not vim.g.vscode,
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
      copilot_model = "gemini-2.5-pro",
    },
  },
  {
    "yetone/avante.nvim",
    build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" or "make",
    cond = not vim.g.vscode,
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "folke/snacks.nvim", -- for input provider snacks
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
    },
    opts = {
      -- provider = "gemini",
      provider = "copilot",
      -- auto_suggestions_provider = "gemini",
      auto_suggestions_provider = "copilot",
      providers = {
        -- gemini = {
        --   -- endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
        --   model = "gemini-2.5-pro",
        -- },
        morph = {
          model = "auto",
        },
      },
      acp_providers = {
        -- ["gemini-cli"] = {
        --   command = "gemini",
        --   args = { "--experimental-acp" },
        --   env = {
        --     NODE_NO_WARNINGS = "1",
        --     GEMINI_API_KEY = os.getenv("GEMINI_API_KEY"),
        --   },
        --   auth_method = "gemini-api-key",
        -- },
      },
      behaviour = {
        auto_suggestions = true, -- Experimental stage
        enable_fastapply = true,  -- Enable Fast Apply feature
      },
      selector = {
        -- "native" | "fzf_lua" | "mini_pick" | "snacks" | "telescope" | fun(selector: avante.ui.Selector): nil
        provider = "fzf_lua",
        provider_opts = {},
        -- exclude_auto_select = { "NvimTree" },
      },
      input = {
        provider = "snacks",
        provider_opts = {
          title = "* Avante Input *",
          icon = "✨",
        },
      },
    },
  },
}
