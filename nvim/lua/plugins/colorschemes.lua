return {
  {"arzg/vim-colors-xcode"},
  {"EdenEast/nightfox.nvim"},
  {
    "oxfist/night-owl.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      -- load the colorscheme here
      require("night-owl").setup()
      vim.cmd.colorscheme("night-owl")
    end,
  },
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    opts = {},
  },
  {
    "rebelot/kanagawa.nvim",
    opts = {
      {
        compile = false,             -- enable compiling the colorscheme
        undercurl = true,            -- enable undercurls
        commentStyle = { italic = true },
        functionStyle = {},
        keywordStyle = { italic = true},
        statementStyle = { bold = true },
        typeStyle = {},
        -- transparent = false,         -- do not set background color
        transparent = true,          -- do not set background color
        dimInactive = false,         -- dim inactive window `:h hl-NormalNC`
        terminalColors = true,       -- define vim.g.terminal_color_{0,17}
        colors = {                   -- add/modify theme and palette colors
          palette = {},
          theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
        },
        theme = "wave",              -- Load "wave" theme
        background = {               -- map the value of 'background' option to a theme
          dark = "wave",           -- try "dragon" !
          light = "lotus"
        },
        overrides = function(colors) -- add/modify highlights
          local theme = colors.theme
          return {
            Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },  -- add `blend = vim.o.pumblend` to enable transparency
            PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
            PmenuSbar = { bg = theme.ui.bg_m1 },
            PmenuThumb = { bg = theme.ui.bg_p2 },
            NormalFloat = { bg = "none" },
            FloatBorder = { bg = "none" },
            FloatTitle = { bg = "none" },
            -- Save an hlgroup with dark background and dimmed foreground
            -- so that you can use it where your still want darker windows.
            -- E.g.: autocmd TermOpen * setlocal winhighlight=Normal:NormalDark
            NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },
            -- Popular plugins that open floats will link to NormalFloat by default;
            -- set their background accordingly if you wish to keep them dark and borderless
            LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
            MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
          }
        end,
      }
    },
  },
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
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
      -- Override highlight groups with your own colour values
      -- highlights = {
        --   -- Highlight groups to override, adding new groups is also possible
        --   -- See `:h highlight-groups` for a list of highlight groups or run `:hi` to see all groups and their current values
        --
        --   -- Example:
        --   Comment = { fg = "#696969", bg = "NONE", italic = true },
        --
        --   -- More examples can be found in `lua/cyberdream/extensions/*.lua`
        -- },
        -- Override a highlight group entirely using the built-in colour palette
        overrides = function(colors) -- NOTE: This function nullifies the `highlights` option
          -- Example:
          return {
            Comment = { fg = colors.green, bg = "NONE", italic = true },
            ["@property"] = { fg = colors.magenta, bold = true },
          }
        end,
        -- Override colors
        colors = {
          -- For a list of colors see `lua/cyberdream/colours.lua`
          -- Override colors for both light and dark variants
          bg = "#000000",
          green = "#00ff00",
          -- If you want to override colors for light or dark variants only, use the following format:
          dark = {
            magenta = "#ff00ff",
            fg = "#eeeeee",
          },
          light = {
            red = "#ff5c57",
            cyan = "#5ef1ff",
          },
        },
        -- Enable or disable specific extensions
        extensions = {
          telescope = false,
          notify = false,
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
  }
