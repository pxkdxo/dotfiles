return {
  {
    "nvim-tree/nvim-tree.lua",
    version = false,
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      hijack_cursor = true,
      reload_on_bufenter = true,
      auto_reload_on_write = true,
      update_focused_file = {
        enable = false,
        update_root = {
          enable = true,
          ignore_list = {
            "Man",
            "NvimTree",
          },
        },
      },
      root_dirs = {
        vim.fn.getcwd(),
        vim.fn.getenv("HOME"),
        vim.fn.stdpath("data"),
        vim.fn.stdpath("config"),
        vim.fn.expand("~/.local"),
      },
      view = {
        side = "right",
        width = {
          min = 22,
          max = "29%",
          padding = 1,
        },
        float = {
          enable = false,
          quit_on_focus_loss = true,
          open_win_config = {
            border = "rounded",
            height = "80%",
            width = "20%",
          },
        },
      },
      diagnostics = {
        enable = true,
        show_on_dirs = true,
        icons = {
          error = " ",
          warning = " ",
          info = " ",
          hint = "󱐌 ",
        },
      },
      renderer = {
        add_trailing = true,
        group_empty = true,
        indent_markers = { enable = true },
        highlight_modified = "all",
        icons = {
          bookmarks_placement = "right_align",
          diagnostics_placement = "right_align",
          symlink_arrow = "🠚 ",
          web_devicons = {
            folder = {
              enable = true,
            },
          },
        },
      },
      modified = {
        enable = true,
      },
      filters = {
        enable = true,
        dotfiles = false,
        git_ignored = false,
      },
    },
    init = function()
      -- Disable netrw
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    config = function(_, opts)
      -- Setup nvim-tre
      require("nvim-tree").setup(opts)

      -- Set key mappings to open/close/locate etc.
      vim.keymap.set("n", "<leader>M", function()
        require("nvim-tree.api").tree.toggle({ focus = false })
      end, { desc = "Toggle File Explorer" })

      vim.keymap.set("n", "<leader>mm", function()
        require("nvim-tree.api").tree.open({ focus = true, find_file = true, update_root = true })
      end, { desc = "Show Current File in File Explorer" })
    end,
  },
}
