return {
  {
    "kylechui/nvim-surround",
    version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    cond = true,
  },
  {
    "ggandor/leap.nvim",
    version = false,
    cond = true,
    opts = {
      preview_filter = function (ch0, ch1, ch2)
        return not (
          ch1:match('%s') or
          ch0:match('%a') and ch1:match('%a') and ch2:match('%a')
        )
      end,
    },
    config = function (_, opts)
      require("leap").setup(opts)
      require('leap.user').set_repeat_keys(
        '<enter>', '<backspace>'
      )
      vim.keymap.set(
        {'n', 'x', 'o'}, 's', '<Plug>(leap)'
      )
      vim.keymap.set(
        {'n'}, 'S', '<Plug>(leap-from-window)'
      )
      vim.api.nvim_set_hl(
        0, 'LeapBackdrop', { link = 'Comment' }
      )
    end,
  },
  {
    "gbprod/yanky.nvim",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    {
      'windwp/nvim-autopairs',
      event = "InsertEnter",
      opts = {
        fast_wrap = {
          chars = { '{', '[', '(', '"', "'" },
          pattern = [=[[%'%"%>%]%)%}%,]]=],
          end_key = '$',
          before_key = 'h',
          after_key = 'l',
          cursor_pos_before = true,
          keys = 'qwertyuiopzxcvbnmasdfghjkl',
          manual_position = true,
          highlight = 'Search',
          highlight_grey='Comment',
        },
      },
    },
  },
  {
    'stevearc/conform.nvim',
    opts = {},
  },
}
