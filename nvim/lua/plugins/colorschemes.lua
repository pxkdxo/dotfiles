return {
  {"arzg/vim-colors-xcode"},
  {"EdenEast/nightfox.nvim"},
  {"nyoom-engineering/oxocarbon.nvim"},
  -- {"oxfist/night-owl.nvim"},
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
  },
  {
    "scottmckendry/cyberdream.nvim",
    opts = {
      -- Set light or dark variant
      variant = "auto", -- use "light" for the light variant. Also accepts "auto" to set dark or light colors based on the current value of `vim.o.background`
      -- Enable transparent background
      transparent = true,
      -- Reduce the overall saturation of colours for a more muted look
      saturation = 0.92, -- accepts a value between 0 and 1. 0 will be fully desaturated (greyscale) and 1 will be the full color (default)
      -- Enable italics comments
      italic_comments = true,
      -- Replace all fillchars with ' ' for the ultimate clean look
      hide_fillchars = false,
      -- Apply a modern borderless look to pickers like Telescope, Snacks Picker & Fzf-Lua
      borderless_pickers = true,
      -- Set terminal colors used in `:terminal`
      terminal_colors = true,
      -- Improve start up time by caching highlights. Generate cache with :CyberdreamBuildCache and clear with :CyberdreamClearCache
      cache = true,
      -- Enable or disable specific extensions
      extensions = {
        telescope = false,
        notify = true,
      },
    },
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = {
      variant = "auto", -- auto, main, moon, or dawn
      dark_variant = "main", -- main, moon, or dawn
      dim_inactive_windows = false,
      extend_background_behind_borders = true,
      enable = {
        terminal = true,
        legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
        migrations = true, -- Handle deprecated options automatically
      },
      styles = {
        bold = true,
        italic = true,
        transparency = true,
      },
      groups = {
        border = "muted",
        link = "iris",
        panel = "surface",
        error = "love",
        hint = "iris",
        info = "foam",
        note = "pine",
        todo = "rose",
        warn = "gold",
        git_add = "foam",
        git_change = "rose",
        git_delete = "love",
        git_dirty = "rose",
        git_ignore = "muted",
        git_merge = "iris",
        git_rename = "pine",
        git_stage = "iris",
        git_text = "rose",
        git_untracked = "subtle",

        h1 = "iris",
        h2 = "foam",
        h3 = "rose",
        h4 = "gold",
        h5 = "pine",
        h6 = "foam",
      },
      highlight_groups = {
        TelescopeBorder = { fg = "highlight_high", bg = "none" },
        TelescopeNormal = { bg = "none" },
        TelescopePromptNormal = { bg = "base" },
        TelescopeResultsNormal = { fg = "subtle", bg = "none" },
        TelescopeSelection = { fg = "text", bg = "base" },
        TelescopeSelectionCaret = { fg = "rose", bg = "rose" },
        CurSearch = { fg = "base", bg = "leaf", inherit = false },
        Search = { fg = "text", bg = "leaf", blend = 20, inherit = false },
      },
    },
  },
  {
    'sainnhe/everforest',
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.everforest_enable_italic = true
    end
  },
  {
    "yorik1984/newpaper.nvim",
    priority = 1000,
    opts = {
      style = "auto", -- dark", "light", or "auto"
      preset = {},
    },
  },
  {
    "zenbones-theme/zenbones.nvim",
    -- Optionally install Lush. Allows for more configuration or extending the colorscheme
    -- If you don't want to install lush, make sure to set g:zenbones_compat = 1
    -- In Vim, compat mode is turned on as Lush only works in Neovim.
    dependencies = "rktjmp/lush.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "eldritch-theme/eldritch.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    'sainnhe/sonokai',
    lazy = false,
    priority = 1000,
    config = function()
      -- Optionally configure and load the colorscheme
      -- directly inside the plugin declaration.
      vim.g.sonokai_enable_italic = true
    end
  },
}
