return {
  {
    "olimorris/codecompanion.nvim",
    opts = {},
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "zbirenbaum/copilot.lua",
    opts = {
      panel = {
        enabled = true,
        -- auto_refresh = false,
        auto_refresh = true,
        -- keymap = {
        --   jump_prev = "[[",
        --   jump_next = "]]",
        --   accept = "<CR>",
        --   refresh = "gr",
        --   open = "<M-CR>"
        -- },
        -- layout = {
        --   position = "bottom", -- | top | left | right | bottom |
        --   ratio = 0.4
        -- },
      },
      suggestion = {
        enabled = true,
        -- auto_trigger = false,
        -- hide_during_completion = true,
        -- debounce = 75,
        debounce = 150,
        -- trigger_on_accept = true,
        -- keymap = {
        --   accept = "<M-l>",
        --   accept_word = false,
        --   accept_line = false,
        --   next = "<M-]>",
        --   prev = "<M-[>",
        --   dismiss = "<C-]>",
        -- },
      },
    },
  },
  -- {
  --   "yetone/avante.nvim",
  --   event = "VeryLazy",
  --   version = false, -- Never set this value to "*"! Never!
  --   -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  --   -- ⚠️ must add this setting! ! !
  --   build = vim.fn.has("win32") ~= 0
  --     and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
  --     or "make",
  --   ---@module 'avante'
  --   ---@type avante.Config
  --   opts = {
  --     ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
  --     ---@type Provider
  --     provider = "gemini", -- The provider used in Aider mode or in the planning phase of Cursor Planning Mode
  --     auto_suggestions_provider = "gemini",
  --     providers = {
  --       gemini = {
  --         endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
  --         model = "gemini-2.5-pro",
  --         timeout = 30000, -- Timeout in milliseconds
  --         temperature = 0,
  --         max_tokens = 8192,
  --       },
  --     },
  --     behaviour = {
  --       auto_suggestions = false, -- Experimental stage
  --       -- auto_set_highlight_group = true,
  --       -- auto_set_keymaps = true,
  --       -- auto_apply_diff_after_generation = false,
  --       support_paste_from_clipboard = true,
  --       -- minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
  --       -- enable_token_counting = true, -- Whether to enable token counting. Default to true.
  --       -- auto_approve_tool_permissions = false, -- Default: show permission prompts for all tools
  --       -- Examples:
  --       -- auto_approve_tool_permissions = true,                -- Auto-approve all tools (no prompts)
  --       -- auto_approve_tool_permissions = {"bash", "replace_in_file"}, -- Auto-approve specific tools only
  --       -- enable_fastapply = true,  -- Enable Fast Apply feature
  --     },
  --     selection = {
  --       -- enabled = true,
  --       -- hint_display = "delayed",
  --     },
  --     suggestion = {
  --       -- debounce = 600,
  --       -- throttle = 600,
  --     },
  --     input = {
  --       -- provider = "native"
  --       provider = "snacks", -- "native" | "dressing" | "snacks"
  --       provider_opts = {
  --         -- Snacks input configuration
  --         title = "Avante Input",
  --         icon = " ",
  --       },
  --     },
  --     selector = {
  --       --- @alias avante.SelectorProvider "native" | "fzf_lua" | "mini_pick" | "snacks" | "telescope" | fun(selector: avante.ui.Selector): nil
  --       --- @type avante.SelectorProvider
  --       provider = "fzf_lua",
  --       -- Options override for custom providers
  --       provider_opts = {},
  --     },
  --     acp_providers = {
  --       ["gemini-cli"] = {
  --         command = "gemini",
  --         args = { "--experimental-acp" },
  --         env = {
  --           NODE_NO_WARNINGS = "1",
  --           GEMINI_API_KEY = os.getenv("GEMINI_API_KEY"),
  --         },
  --       },
  --     }
  --   },
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "MunifTanjim/nui.nvim",
  --     --- The below dependencies are optional,
  --     "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
  --     "ibhagwan/fzf-lua", -- for file_selector provider fzf
  --     -- "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
  --     -- "echasnovski/mini.pick", -- for file_selector provider mini.pick
  --     -- "stevearc/dressing.nvim", -- for input provider dressing
  --     "folke/snacks.nvim", -- for input provider snacks
  --     -- "zbirenbaum/copilot.lua", -- for providers='copilot'
  --     "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
  --     -- "echasnovski/mini.icons", -- or nvim-tree/nvim-web-devicons
  --     {
  --       -- support for image pasting
  --       "HakonHarnes/img-clip.nvim",
  --       event = "VeryLazy",
  --       opts = {
  --         -- recommended settings
  --         default = {
  --           embed_image_as_base64 = false,
  --           prompt_for_file_name = false,
  --           drag_and_drop = {
  --             insert_mode = true,
  --           },
  --           -- required for Windows users
  --           use_absolute_path = true,
  --         },
  --       },
  --     },
  --     {
  --       -- Make sure to set this up properly if you have lazy=true
  --       'MeanderingProgrammer/render-markdown.nvim',
  --       opts = {
  --         file_types = { "markdown", "Avante" },
  --       },
  --       ft = { "markdown", "Avante" },
  --     },
  --   },
  -- },
}
