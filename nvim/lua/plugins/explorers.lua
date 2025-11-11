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
        vim.fn.expand("~/"),
        vim.fn.expand("~/.local"),
        vim.fn.stdpath("data"),
        vim.fn.stdpath("config"),
      },
      view = {
        width = {
          min = 5,
          max = "22%",
          padding = 0,
        },
        float = {
          enable = false,
          quit_on_focus_loss = true,
          open_win_config = {},
        },
      },
      renderer = {
        add_trailing = true,
        indent_markers = { enable = true },
        icons = { web_devicons = { folder = { enable = true } } },
      },
      diagnostics = { enable = true },
      filters = {
        enable = true,
        dotfiles = false,
        git_ignored = false,
      },
    },
    config = function(_, opts)
      -- Setup nvim-tre
      require("nvim-tree").setup(opts)

      -- Set key mappings to open/close/locate etc.
      vim.keymap.set('n', '<leader>/', function ()
        require('nvim-tree.api').tree.toggle({ focus = false })
      end, { desc = "Toggle File Explorer" })

      vim.keymap.set('n', '<leader>.', function ()
        require('nvim-tree.api').tree.open({ focus = true, find_file = true, update_root = true })
      end, { desc = "Show Current File in File Explorer" })
    end,
  },
}
