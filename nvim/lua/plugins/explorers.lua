return {
  {
    "nvim-tree/nvim-tree.lua",
    version = false,
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    cond = not vim.g.vscode,
    opts = {
      reload_on_bufenter = true,
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
            width = 30,
            height = 75,
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
          web_devicons = {
            file = {
              enable = true,
            },
            folder = {
              enable = true,
            },
          },
        },
      },
      filters = {
        enable = true,
        git_ignored = true,
        dotfiles = false,

      },
    },
    config = function(_, opts)
      -- disable netrw
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      require("nvim-tree").setup(opts)
    end,
  },
}
