return {
  {
    'nvim-mini/mini.icons',
    version = false,
    lazy = true,
    opts = {},
    config = function (_, opts)
      local mini_icons = require('mini.icons')
      mini_icons.setup(opts)
      MiniIcons.mock_nvim_web_devicons()
    end
  },
  -- {
  --   'nvim-mini/mini.animate',
  --   version = false,
  --   lazy = true,
  --   opts = {},
  -- },
}
