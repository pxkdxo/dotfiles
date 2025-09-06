return {
  {
    'akinsho/bufferline.nvim',
    version = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons'
    },
    opts = {
      options = {
        themable = true, -- allows highlight groups to be overriden i.e. sets highlights as default
        color_icons = true, -- whether or not to add the filetype icon highlights
        show_buffer_icons = true, -- disable filetype icons for buffers
        separator_style = "thick"
      }
    },
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons'
    },
    opts = {
      options = {
        theme = "auto", -- "auto" will set the theme dynamically based on the colorscheme
      },
    }
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    opts = {
      indent = {
        -- char = "│",
        char = "▎",
      },
      scope = {
        enabled = true
      }
    },
  },
}

