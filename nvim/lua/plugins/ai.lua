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
        enabled = false,
        -- enabled = true,
        -- -- auto_refresh = false,
        -- auto_refresh = true,
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
        -- enabled = true,
        enabled = false,
        -- auto_trigger = false,
        -- hide_during_completion = true,
        -- debounce = 75,
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
      filetypes = {
        -- yaml = false,
        -- markdown = false,
        -- help = false,
        -- gitcommit = false,
        -- gitrebase = false,
        -- hgcommit = false,
        -- svn = false,
        -- cvs = false,
        -- ["."] = false,
      },
      -- auth_provider_url = nil, -- URL to authentication provider, if not "https://github.com/"
      logger = {
        -- file = vim.fn.stdpath("log") .. "/copilot-lua.log",
        -- file_log_level = vim.log.levels.OFF,
        -- print_log_level = vim.log.levels.WARN,
        -- trace_lsp = "off", -- "off" | "messages" | "verbose"
        -- trace_lsp_progress = false,
        -- log_lsp_messages = false,
      },
      -- copilot_node_command = 'node', -- Node.js version must be > 20
      -- workspace_folders = {},
      -- copilot_model = "",
      -- disable_limit_reached_message = false,  -- Set to `true` to suppress completion limit reached popup
      -- root_dir = function()
      --   return vim.fs.dirname(vim.fs.find(".git", { upward = true })[1])
      -- end,
      -- should_attach = function(_, _)
      --   if not vim.bo.buflisted then
      --     logger.debug("not attaching, buffer is not 'buflisted'")
      --     return false
      --   end

      --   if vim.bo.buftype ~= "" then
      --     logger.debug("not attaching, buffer 'buftype' is " .. vim.bo.buftype)
      --     return false
      --   end

      --   return true
      -- end,
      -- server = {
      --   type = "nodejs", -- "nodejs" | "binary"
      --   custom_server_filepath = nil,
      -- },
      -- server_opts_overrides = {},
    },
  },
  -- {
  --   "yetone/avante.nvim",
  --   -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  --   -- ⚠️ must add this setting! ! !
  --   build = vim.fn.has("win32") ~= 0
  --     and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
  --     or "make",
  --   event = "VeryLazy",
  --   version = false, -- Never set this value to "*"! Never!
  --   ---@module 'avante'
  --   ---@type avante.Config
  --   opts = {
  --     -- add any opts here
  --     -- for example
  --     input = {
  --       provider = "native", -- "native" | "dressing" | "snacks"
  --     },
  --     selector = {
  --       --- @alias avante.SelectorProvider "native" | "fzf_lua" | "mini_pick" | "snacks" | "telescope" | fun(selector: avante.ui.Selector): nil
  --       --- @type avante.SelectorProvider
  --       provider = "fzf_lua",
  --       -- Options override for custom providers
  --       provider_opts = {},
  --     },
  --     -- provider = "claude",
  --     provider = "copilot",
  --     -- providers = {},
  --     behaviour = {
  --       auto_suggestions = true, -- Experimental stage
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
  --     },
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
  --     -- "folke/snacks.nvim", -- for input provider snacks
  --     "zbirenbaum/copilot.lua", -- for providers='copilot'
  --     "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
  --     "echasnovski/mini.icons", -- or nvim-tree/nvim-web-devicons
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
