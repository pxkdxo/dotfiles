return {
  {
    "L3MON4D3/LuaSnip",
    -- Follow latest release.
    version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- Install jsregexp (optional!)
    -- build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
  },
  { "rafamadriz/friendly-snippets" },
}
