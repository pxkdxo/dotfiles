return {
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    opts = {
      -- preset = "classic",
      --transparent_bg = false,
      transparent_bg = true,
      transparent_cursorline = true,
      options = {
        -- Settings for multiline diagnostics
        multilines = {
          -- enabled = false,           -- Enable support for multiline diagnostic messages
          enabled = true,           -- Enable support for multiline diagnostic messages
          -- always_show = false,       -- Always show messages on all lines of multiline diagnostics
          -- trim_whitespaces = false,  -- Remove leading/trailing whitespace from each line
          -- tabstop = 4,               -- Number of spaces per tab when expanding tabs
          -- severity = nil,            -- Filter multiline diagnostics by severity (e.g., { vim.diagnostic.severity.ERROR })
        },
        add_messages = {
          display_count = true,
        },
        -- Only show source if multiple sources exist for the same diagnostic 
        show_source = { if_many = true },
        -- Throttle update frequency in milliseconds to improve performance
        -- Higher values reduce CPU usage but may feel less responsive
        -- Set to 0 for immediate updates (may cause lag on slow systems)
        --throttle = 20,
        throttle = 5,
      },
      signs = {
        left         = "",
        right        = "",
        diag         = "✶", -- ⏺ 󱨧 󰦥 ⌑ ✦ ✧ ✱ ⛤ ⛧ ✹ ✸ ✶    ●
        arrow        = " ⇐  ", -- ↜ ⇐ 󱖚 󰬩 󰧙 󰳞 󰩔      󰶢  󰧀
        up_arrow     = " ↑  ", -- ↑ ⇞ 󰩕  󰧇     󰛃 󰳡 󱖗
        vertical     = " │",
        vertical_end = " ╰",
      },
      blend = {
        factor = 0.28,
      },
    },
    config = function(_, opts)
      local tid = require('tiny-inline-diagnostic')
      tid.setup(opts)
      vim.diagnostic.open_float = tid.open_float
      vim.diagnostic.config({ virtual_text = false }) -- Disable default virtual text
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
        "<leader>xL",
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
        return vim.tbl_deep_extend(
          "force", opts or {}, {
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
          }
        )
      end,
    },
  },
}
