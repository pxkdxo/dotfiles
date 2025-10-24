return {
  {
    'numToStr/Comment.nvim',
    opts = {
      ignore = '^$',
      toggler = {
        line = '<leader>cc',
        block = '<leader>CC',
      },
      extra = {
        above = '<leader>cO',
        below = '<leader>co',
        eol = '<leader>cA',
      },
      opleader = {
        line = '<leader>c',
        block = '<leader>C',
      },
    },
  },
  {
    "danymat/neogen",
    config = true,
    cond = false,
    -- Uncomment next line if you want to follow only stable versions
    -- version = "*" 
  },

}
