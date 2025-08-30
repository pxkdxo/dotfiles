return {
  {
    "mikavilpas/yazi.nvim",
    version = false, -- use the latest stable version
    event = "VeryLazy",
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
    },
    keys = {
      -- 👇 in this section, choose your own keymappings!
      {
        "<leader>-",
        mode = { "n", "v" },
        "<cmd>Yazi<cr>",
        desc = "Open yazi at the current file",
      },
      {
        -- Open in the current working directory
        "<leader>cw",
        "<cmd>Yazi cwd<cr>",
        desc = "Open the file manager in nvim's working directory",
      },
      {
        "<c-up>",
        "<cmd>Yazi toggle<cr>",
        desc = "Resume the last yazi session",
      },
    },
    ---@type YaziConfig | {}
    opts = {
      -- if you want to open yazi instead of netrw, see below for more info
      open_for_directories = false,
      keymaps = {
        show_help = "<f1>",
      },
    },
    -- 👇 if you use `open_for_directories=true`, this is recommended
    -- init = function()
    --   -- mark netrw as loaded so it's not loaded at all.
    --   --
    --   -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
    --   vim.g.loaded_netrw = 1
    --   vim.g.loaded_netrwPlugin = 1
    -- end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    version = false,
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      -- disable netrw
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      return require("nvim-tree").setup({
        -- on_attach = "default",
        -- hijack_cursor = false,
        -- auto_reload_on_write = true,
        -- disable_netrw = false,
        -- hijack_netrw = true,
        -- hijack_unnamed_buffer_when_opening = false,
        -- root_dirs = {},
        -- prefer_startup_root = false,
        -- sync_root_with_cwd = false,
        -- reload_on_bufenter = false,
        -- respect_buf_cwd = false,
        -- select_prompts = false,
        -- sort = {
        -- sorter = "name",
        -- folders_first = true,
        -- files_first = false,
        -- },
        view = {
          -- centralize_selection = false,
          -- cursorline = true,
          -- cursorlineopt = "both",
          -- debounce_delay = 15,
          -- side = "left",
          -- preserve_window_proportions = true,
          -- number = false,
          -- relativenumber = false,
          -- signcolumn = "yes",
          width = 55,
          float = {
            enable = true,
            quit_on_focus_loss = true,
            open_win_config = {
              relative = "editor",
              border = "double",
              width = 35,
              height = 50,
              row = 1,
              col = 1,
            },
          },
        },
        renderer = {
          add_trailing = true,
          group_empty = true,
          indent_markers = {
            enable = true,
            inline_arrows = true,
            -- icons = {
            --   corner = "└",
            --   edge = "│",
            --   item = "│",
            --   bottom = "─",
            --   none = " ",
            -- },
          },
          icons = {
            web_devicons = {
              file = {
                enable = true,
                color = true,
              },
              folder = {
                enable = true,
                color = true,
              },
            },
          },
        },
        filters = {
          enable = true,
          git_ignored = true,
          dotfiles = false,
        },
      })
    end,
  },
}
