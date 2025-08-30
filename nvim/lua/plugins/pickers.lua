return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  {
    'echasnovski/mini.pick',
    version = false,
  },
  {
    "ibhagwan/fzf-lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      -- or
      -- "echasnovski/mini.icons",
    },
    opts = {
      -- Base Profile
      "border-fused",
      -- UI Options
      winopts = {
        -- split = "belowright new" -- open a split window below
        -- or
        -- split = "belowright vsplit" -- open a split window to the right
        -- or, when using a floating window
        height           = 0.85,            -- window height
        width            = 0.80,            -- window width
        row              = 0.35,            -- window row position (0=top, 1=bottom)
        col              = 0.50,            -- window col position (0=left, 1=right)
        -- Backdrop opacity, 0 is fully opaque, 100 is fully transparent (i.e. disabled)
        backdrop         = 60,
        fullscreen       = false,
        -- Enable treesitter highlighting for the main fzf window
        treesitter       = {
          enabled    = true,
          fzf_colors = { ["hl"] = "-1:reverse", ["hl+"] = "-1:reverse" }
        },
        preview = {
          default        = 'bat',
          layout         = "flex",          -- horizontal|vertical|flex
          scrolloff      = -1,              -- float scrollbar offset from right
        },
        on_create = function()
            vim.keymap.set("t", "<C-j>", "<Down>", { silent = true, buffer = true })
        end,
        -- called once _after_ the fzf interface is closed
        -- on_close = function() ... end
      },
      -- Neovim keymaps / fzf binds
      keymap = {
        ["--bind"] = "ctrl-b:page-up",
        ["--bind"] = "ctrl-f:page-down",
        ["--bind"] = "ctrl-j:replace-query",
        ["--bind"] = "ctrl-k:kill-line",
        ["--bind"] = "ctrl-o:execute-silent(printf %s {} | xclip -selection clipboard)",
        ["--bind"] = "ctrl-/:toggle-preview",
        ["--bind"] = "ctrl-]:jump-accept",
        ["--bind"] = "insert:replace-query",
      },
      -- fzf "accept" binds
      --actions = {},
      -- fzf command options
      fzf_opts = {
        ["--ansi"]   = true,
        ["--style"]  = "full",
        ["--border"] = "sharp",
        ["--color"]  = "dark,header:1,info:3,pointer:5,prompt:5,border:5,fg:4,fg+:6,hl:6,hl+:5",
        ["--prompt"] = "> ",
        ["--info"]   = "inline-right",
        ["--layout"] = "reverse",
        ["--tmux"]   = "center,80%,60%",
        ["--ghost"]  = "start typing to search",
        ["--input-border"] = "line",
        -- ["--info-command"] = "printf '\\e[0m%s%d\\e[0m%s Matches\\e[0m %s(\\e[0m%s%d\\e[0m%s Selected\\e[0m%s)\\e[0m %s/\\e[0m %s%d\\e[0m%s Total\\e[0m' \"$(tput setaf 9; tput bold)\" \"${FZF_MATCH_COUNT}\" \"$(tput setaf 9)\" \"$(tput setaf 15; tput sitm)\" \"$(tput setaf 7; tput dim; tput bold; tput sitm)\" \"${FZF_SELECT_COUNT}\" \"$(tput setaf 7; tput dim; tput sitm)\" \"$(tput setaf 15; tput sitm)\" \"$(tput setaf 15)\" \"$(tput setaf 14; tput bold)\" \"${FZF_TOTAL_COUNT}\" \"$(tput setaf 14)\""
      },
      -- fzf_colors = {},  -- Fzf `--color` specification
      -- hls = {},         -- Highlights
      -- previewers = {},  -- Previewers options
      -- files = { ... },
    },
  },
}
