return {
  {
    "ravitemer/mcphub.nvim",
    cond = vim.g.vscode == nil and vim.fn.executable("npm") == 1,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "npm install -g mcp-hub@latest",  -- Installs `mcp-hub` node binary globally
    config = function(_, opts)
      require("mcphub").setup()
    end
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
          adapter = "copilot",
          model   = "gpt-5",
        },
        inline = {
          adapter = "copilot",
          model   = "gpt-5",
        },
      },
      extensions = {
        history = {
          enabled = true, -- defaults to true
          opts = {
            dir_to_save = vim.fn.stdpath("data") .. "/codecompanion/chat_history.json",
          }
        },
        -- mcphub = {
        --   callback = "mcphub.extensions.codecompanion",
        --   opts = {
        --     -- MCP Tools
        --     make_tools = true,              -- Make individual tools (@server__tool) and server groups (@server) from MCP servers
        --     show_server_tools_in_chat = true, -- Show individual tools in chat completion (when make_tools=true)
        --     add_mcp_prefix_to_tool_names = false, -- Add mcp__ prefix (e.g `@mcp__github`, `@mcp__neovim__list_issues`)
        --     show_result_in_chat = true,      -- Show tool results directly in chat buffer
        --     format_tool = nil,               -- function(tool_name:string, tool: CodeCompanion.Agent.Tool) : string Function to format tool names to show in the chat buffer
        --     -- MCP Resources
        --     make_vars = true,                -- Convert MCP resources to #variables for prompts
        --     -- MCP Prompts
        --     make_slash_commands = true,      -- Add MCP prompts as /slash commands
        --   }
        -- }
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
