return {
  -- {
  --   "olimorris/codecompanion.nvim",
  --   opts = {},
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --   },
  -- },
  {
    "zbirenbaum/copilot.lua",
    opts = {
      panel = {
        enabled = true,
        auto_refresh = false,
        keymap = {
          jump_prev = "[[",
          jump_next = "]]",
          accept = "<CR>",
          refresh = "gr",
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
        debounce = 100,
        trigger_on_accept = true,
        keymap = {
          accept = "<M-l>",
          accept_word = false,
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      copilot_node_command = 'node', -- Node.js version must be > 20
      workspace_folders = {},
      copilot_model = "gemini-2.5-pro",
      disable_limit_reached_message = false,  -- Set to `true` to suppress completion limit reached popup
      server_opts_overrides = {},
    },
  },
  {
    "yetone/avante.nvim",
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    -- ⚠️ must add this setting! ! !
    build = vim.fn.has("win32") ~= 0
    and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
    or "make",
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
      -- this file can contain specific instructions for your project
      -- instructions_file = "avante.md",
      provider = "copilot",
      -- provider = "gemini",
      -- provider = "gemini-cli",
      auto_suggestions_provider = "gemini",
      providers = {
        gemini = {
          -- endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
          model = "gemini-2.5-pro",
        },
        morph = {
          model = "auto",
        },
      },
      acp_providers = {
        ["gemini-cli"] = {
          command = "gemini",
          args = { "--experimental-acp" },
          env = {
            NODE_NO_WARNINGS = "1",
            GEMINI_API_KEY = os.getenv("GEMINI_API_KEY"),
          },
          auth_method = "gemini-api-key",
        },
      },
      behaviour = {
        auto_suggestions = false, -- Experimental stage
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
          title = "[Avante Input]",
          icon = " ",
        },
      },
    },
  },
}
