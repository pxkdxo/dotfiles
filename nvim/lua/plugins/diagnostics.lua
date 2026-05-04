return {
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    opts = {
      -- preset = "classic",
      --transparent_bg = false,
      transparent_bg = true,
      options = {
        -- Settings for multiline diagnostics
        multilines = {
          enabled = true, -- Enable support for multiline diagnostic messages
          -- always_show = false,       -- Always show messages on all lines of multiline diagnostics
          -- trim_whitespaces = false,  -- Remove leading/trailing whitespace from each line
          -- tabstop = 4,               -- Number of spaces per tab when expanding tabs
          -- severity = nil,            -- Filter multiline diagnostics by severity (e.g., { vim.diagnostic.severity.ERROR })
        },
        add_messages = {
          display_count = true,
        },
        -- Only show source if multiple sources exist for the same diagnostic
        show_source = { enabled = true, if_many = true },
        -- Throttle update frequency in milliseconds to improve performance
        -- Higher values reduce CPU usage but may feel less responsive
        -- Set to 0 for immediate updates (may cause lag on slow systems)
        --throttle = 20,
        throttle = 5,
      },
      signs = {
        left = " ",
        right = " ",
        diag = "󱨧", --  󱨧 ✦ ✧ ✱ ⛤ ⛧ ✹ ✸ ✶   󰎂 󰎃
        arrow = "", --  󰩔 󱖚 󰬩 󰧙 󰳞     󰧀
        up_arrow = "󰩕", --  ↑ 󰩕 󱖗 󰧇      󰛃 󰜸 
        vertical = " 󰇝", --   󰇝 󱋱 󰇙 󰟄 󰮎  󰮾  󰝀 󰜹  
        vertical_end = " ",
      },
      blend = {
        factor = 0.28,
      },
    },
    config = function(_, opts)
      local tid = require("tiny-inline-diagnostic")
      tid.setup(opts)
      vim.diagnostic.config({ virtual_text = false })
    end,
  },
  {
    "folke/todo-comments.nvim",
    cond = vim.g.vscode == nil,
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      {
        "]t",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Next TODO comment",
      },
      {
        "[t",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "Previous TODO comment",
      },
      { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "TODOs (Trouble)" },
      { "<leader>xT", "<cmd>Trouble todo toggle filter={tag={TODO,FIX,FIXME}}<cr>", desc = "TODO/FIX/FIXME (Trouble)" },
    },
  },
  {
    "mfussenegger/nvim-lint",
    cond = vim.g.vscode == nil,
    event = { "BufReadPost", "BufNewFile", "BufWritePost" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        bash = { "shellcheck" },
        dockerfile = { "hadolint" },
        go = { "golangcilint" },
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        markdown = { "markdownlint" },
        python = { "ruff" },
        sh = { "shellcheck" },
        terraform = { "tflint" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        yaml = { "yamllint" },
        zsh = { "zsh" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = function()
          if vim.bo.buftype == "" then
            lint.try_lint()
          end
        end,
      })
    end,
  },
  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>x-",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>xS",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xl",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
    specs = {
      "folke/snacks.nvim",
      cond = vim.g.vscode == nil,
      opts = function(_, opts)
        return vim.tbl_deep_extend("force", opts or {}, {
          picker = {
            actions = require("trouble.sources.snacks").actions,
            win = {
              input = {
                keys = {
                  ["<c-t>"] = {
                    "trouble_open",
                    mode = { "n", "i" },
                  },
                },
              },
            },
          },
        })
      end,
    },
  },
}
