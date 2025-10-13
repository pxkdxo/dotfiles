return {
  {
    'L3MON4D3/LuaSnip',
    -- Follow latest release.
    version = 'v2.*',
    -- Install jsregexp (optional!)
    -- build = 'make install_jsregexp',
    dependencies = {
      'rafamadriz/friendly-snippets',
    },
    cond = not vim.g.vscode,
    opts = {},
    config = function (_, opts)
      require('luasnip').setup(opts)
      require('luasnip.loaders.from_vscode').lazy_load()
    end,
  },
}
