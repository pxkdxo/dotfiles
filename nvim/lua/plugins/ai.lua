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
          }
        }
      }
    end,
    config = function(_, opts)
      require("mcphub").setup(opts)
    end
  },
  {
    "yetone/avante.nvim",
    cond = vim.g.vscode == nil,
    build = "make",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
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
      -- this file can contain specific instructions for your project
      instructions_file = "avante.md",

      provider = "cursor",
      mode = "agentic",
      behaviour = {
        auto_suggestions = false,
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
      acp_providers = {
        cursor = {
          command = vim.fn.exepath("cursor-agent"),
          args = { "acp" },
          auth_method = "cursor_login",
          env = {
            HOME = os.getenv("HOME"),
            PATH = os.getenv("PATH"),
          },
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
          title = "*avante input*",
        },
      },
      selector = {
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
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {"HakonHarnes/img-clip.nvim"},
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
  {
    "zbirenbaum/copilot.lua",
    cond = vim.g.vscode == nil,
    -- cond = false,
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
      copilot_node_command = 'node',
      workspace_folders = {},
    },
  },
  {
    'Exafunction/windsurf.vim',
    cond = false,
    -- cond = vim.g.vscode == nil,
    event = 'BufEnter'
  },
  {
    "olimorris/codecompanion.nvim",
    -- cond = vim.g.vscode == nil,
    cond = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/mcphub.nvim",
      "ravitemer/codecompanion-history.nvim",
    },
    opts = {
      adapters = {
        acp = {
          codex = function()
            return require("codecompanion.adapters").extend("codex", {
              defaults = {
                auth_method = "openai-api-key", -- "openai-api-key"|"codex-api-key"|"chatgpt"
              },
              env = {
                OPENAI_API_KEY = os.getenv("OPENAI_API_KEY"),
              },
            })
          end,
          gemini_cli = function()
            return require("codecompanion.adapters").extend("gemini_cli", {
              defaults = {
                auth_method = "gemini-api-key", -- "oauth-personal"|"gemini-api-key"|"vertex-ai"
              },
              env = {
                GEMINI_API_KEY = os.getenv("GEMINI_API_KEY"),
              },
            })
          end,
        },
      },
      interactions = {
        --NOTE: Change the adapter as required
        chat = {
          adapter = "copilot",
          model   = "gpt-5.3-codex",
        },
        inline = {
          adapter = "copilot",
          model   = "gpt-5.3-codex",
        },
        cmd = {
          adapter = "codex",
          opts = {
            completion_provider = "cmp", -- blink|cmp|coc|default
          }
        },
        -- background = {
        --   adapter = {
        --     name = "ollama",
        --     model = "qwen-7b-instruct",
        --   },
        -- }
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
            -- MCP Prompts
            make_slash_commands = true,
            -- MCP Resources
            make_vars = false, -- Broken, tries to access 'variables'
           },
        },
      }
    },
  },
}
