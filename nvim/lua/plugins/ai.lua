return {
  {
    "ravitemer/mcphub.nvim",
    cond = vim.g.vscode == nil,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- Only run the global npm install when npm is actually available.
    -- The plugin itself works without npm at runtime when `server_url` points
    -- at an externally-managed mcp-hub (e.g. systemd/launchd-supervised).
    build = vim.fn.executable("npm") == 1 and "npm install -g mcp-hub@latest" or nil,
    opts = function()
      return {
        -- Connect to the launchd-managed mcp-hub at ~/Library/LaunchAgents/com.patrickdeyoreo.mcphub.plist
        -- instead of spawning a duplicate on a different port. Falls back to
        -- the plugin spawning its own hub if this URL is unreachable.
        server_url = "http://localhost:37373",
        native_servers = {
          orchestrator = require("servers.orchestrator"),
        },
        extensions = {
          avante = {
            make_slash_commands = true, -- make /slash commands from MCP server prompts
            make_tools = true,
            make_vars = true,
          },
        },
      }
    end,
    config = function(_, opts)
      require("mcphub").setup(opts)
    end,
  },
  {
    "yetone/avante.nvim",
    cond = vim.g.vscode == nil,
    build = "make",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    keys = {
      {
        "<leader>a<Tab>",
        function()
          require("avante.extensions.nvim_tree").add_file()
        end,
        desc = "Select file in NvimTree",
        ft = "NvimTree",
      },
      {
        "<leader>a<S-Tab>",
        function()
          require("avante.extensions.nvim_tree").remove_file()
        end,
        desc = "Deselect file in NvimTree",
        ft = "NvimTree",
      },
    },
    opts = {
      -- this file can contain specific instructions for your project
      instructions_file = "avante.md",
      mode = "agentic",
      provider = "cursor",
      auto_suggestions_provider = "claude-code",
      behaviour = {
        auto_suggestions = true,
        enable_fastapply = true,
        auto_add_current_file = true,
        auto_approve_tool_permissions = true,
      },
      ask = {
        floating = true, -- Open the 'AvanteAsk' prompt in a floating window
        start_insert = true, -- Start insert mode when opening the ask window
        border = "rounded",
        ---@type "ours" | "theirs"
        focus_on_apply = "ours", -- which diff to focus after applying
      },
      providers = {
        claude = {
          auth_type = "max",
          model = "claude-haiku-4.5",
        },
      },
      acp_providers = {
        ["cursor"] = {
          command = vim.fn.exepath("cursor-agent"),
          args = { "acp" },
          auth_method = "cursor_login",
          env = {
            HOME = os.getenv("HOME"),
            PATH = os.getenv("PATH"),
          },
        },
        ["claude-code"] = {
          auth_type = "max",
          command = "npx",
          args = { "@zed-industries/claude-code-acp" },
          env = {
            NODE_NO_WARNINGS = "1",
            CLAUDE_CODE_OAUTH_TOKEN = os.getenv("CLAUDE_CODE_OAUTH_TOKEN"),
            ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY"),
          },
        },
      },
      shortcuts = {
        {
          name = "refactor",
          description = "Refactor code with best practices",
          prompt = "Please refactor this code following best practices.",
        },
      },
      system_prompt = function()
        local hub = require("mcphub").get_hub_instance()
        return hub and hub:get_active_servers_prompt() or ""
      end,
      -- Using function prevents requiring mcphub before it's loaded
      custom_tools = function()
        return {
          require("mcphub.extensions.avante").mcp_tool(),
        }
      end,
      -- mcphub provides equivalent tools
      disabled_tools = {
        "list_files", -- Built-in file operations
        "search_files",
        "read_file",
        "create_file",
        "rename_file",
        "delete_file",
        "create_dir",
        "rename_dir",
        "delete_dir",
        "bash", -- Built-in terminal access
      },
      spinner = {
        generating = {
          "·",
          "✢",
          "✳",
          "∗",
          "✻",
          "✽",
        }, -- Spinner characters for the 'generating' state
        thinking = {
          "·   ✧",
          "·  ✧ ",
          "· ✧  ",
          "✧·   ",
          " ✧·  ",
          "  ✧· ",
          "   ✧·",
          "  ✧· ",
          " ✧·  ",
          "✧·   ",
          "· ✧  ",
          "·  ✧ ",
        },
      },
      input = {
        provider = "snacks",
        enabled = true,
        provider_opts = {
          title = "<avante input>",
        },
      },
      selector = {
        provider = "fzf_lua",
        provider_opts = {},
        exclude_auto_select = { "NvimTree" },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      -- "nvim-mini/mini.pick", -- for file_selector provider mini.pick
      -- "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "stevearc/dressing.nvim", -- for input provider dressing
      "folke/snacks.nvim", -- for input provider snacks
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      -- "zbirenbaum/copilot.lua", -- for providers='copilot'
      { "HakonHarnes/img-clip.nvim" },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
  {
    "zbirenbaum/copilot.lua",
    -- cond = vim.g.vscode == nil,
    cond = false,
    event = "InsertEnter",
    cmd = "Copilot",
    opts = {
      panel = { enabled = false },
      suggestion = {
        enabled = true,
        auto_refresh = true,
        hide_during_completion = true,
        debounce = 150,
        trigger_on_accept = true,
        keymap = {
          accept = "<M-Space>",
          accept_line = "<M-Bslash>",
          accept_word = "<C-Right>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<M-BS>",
        },
      },
      copilot_node_command = "node",
      workspace_folders = {},
    },
  },
  {
    "Exafunction/windsurf.vim",
    cond = false,
    -- cond = vim.g.vscode == nil,
    event = "BufEnter",
  },
  {
    "olimorris/codecompanion.nvim",
    cond = vim.g.vscode == nil,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/mcphub.nvim",
      "ravitemer/codecompanion-history.nvim",
    },
    opts = {
      interactions = {
        --NOTE: Change the adapter as required
        chat = {
          adapter = "claude",
          model = "claude-sonnet-4.6",
        },
        inline = {
          adapter = "claude",
          model = "claude-haiku-4.5",
        },
      },
      extensions = {
        history = {
          enabled = true, -- defaults to true
          opts = {
            dir_to_save = vim.fn.stdpath("data") .. "/codecompanion/chat_history.json",
          },
        },
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            -- MCP Tools
            make_tools = true,
            show_server_tools_in_chat = true,
            add_mcp_prefix_to_tool_names = false,
            show_result_in_chat = true,
            -- MCP Resources
            make_vars = false, -- Broken, tries to access 'variables'
            -- MCP Prompts
            make_slash_commands = true,
          },
        },
      },
    },
  },
}
