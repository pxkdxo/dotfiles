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
      interactions = {
        --NOTE: Change the adapter as required
        chat = {
          adapter = "copilot",
          model   = "gpt-5",
        },
        inline = {
          adapter = "copilot",
          model   = "gpt-5",
        },
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
