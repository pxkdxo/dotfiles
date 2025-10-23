return {
  {
    "nvim-tree/nvim-tree.lua",
    version = false,
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    opts = {
      hijack_cursor = true,
      reload_on_bufenter = true,
      root_dirs = {
        vim.fn.getcwd(),
        os.getenv("HOME"),
        os.getenv("HOME") .. "/.local",
      },
      view = {
        width = {
          min = 12,
          max = "28%",
          padding = 1,
        },
        float = {
          enable = false,
          quit_on_focus_loss = true,
          open_win_config = {
            relative = "win",
            border = "rounded",
            width = 32,
            height = "80%",
            row = 1,
            col = 1,
          },
        },
      },
      renderer = {
        add_trailing = true,
        indent_markers = {
          enable = true,
        },
        icons = {
          web_devicons = { folder = { enable = true } },
        },
      },
      diagnostics = { enable = true},
      filters = {
        enable = true,
        git_ignored = false,
        dotfiles = false,

      },
    },
    config = function(_, opts)
      -- Setup nvim-tre
      require("nvim-tree").setup(opts)

      -- Set key mappings to open/close/locate etc.
      local api = require('nvim-tree.api')

      vim.keymap.set('n', '<leader>e', function ()
        api.tree.toggle({ focus = false })
      end, { desc = "Toggle File Explorer" })

      vim.keymap.set('n', '<leader>E', function ()
        api.tree.open({ focus = true, find_file = true, update_root = true })
      end, { desc = "Show Current File in File Explorer" })
    end,
  },
}
