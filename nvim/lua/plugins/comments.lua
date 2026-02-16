return {
  {
    'numToStr/Comment.nvim',
    opts = {
      ignore = '^$',
      toggler = {
        line = '<leader>\\\\',
        block = '<leader>;',
      },
      extra = {
        above = '<leader>\\k',
        below = '<leader>\\j',
        eol = '<leader>\\$',
      },
      opleader = {
        line = '<leader>\\',
        block = '<leader>;',
      },
    },
  },
  {
    "danymat/neogen",
    -- cond = false,
    -- Uncomment next line if you want to follow only stable versions
    version = "*"
  },

}
