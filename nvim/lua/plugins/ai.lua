return {
  {
    "ravitemer/mcphub.nvim",
    cond = vim.g.vscode == nil and vim.fn.executable("npm") == 1,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "npm install -g mcp-hub@latest",  -- Installs `mcp-hub` node binary globally
    config = function()
      require("mcphub").setup({})
    end
  },
  {
    "olimorris/codecompanion.nvim",
    cond = vim.g.vscode == nil,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/mcphub.nvim",
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
          adapter = "gemini_cli",
          -- model   = "gpt-5",
          opts = {
            completion_provider = "cmp", -- blink|cmp|coc|default
          }
        },
        inline = {
          adapter = "gemini",
          -- model   = "gpt-5",
          opts = {
            completion_provider = "cmp", -- blink|cmp|coc|default
          }
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
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            make_tools = true,
            show_server_tools_in_chat = true,
            show_result_in_chat = true,
            make_vars = true,
            make_slash_commands = true,
          }
        }
      }
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
        hide_during_completion = false,
        debounce = 80,
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
    'Exafunction/windsurf.vim',
    cond = false,
    -- cond = vim.g.vscode == nil,
    event = 'BufEnter'
  },
}
