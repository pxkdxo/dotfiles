return {
  {
    'echasnovski/mini.pick',
    version = '*'
  },
  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- or
    -- dependencies = { "echasnovski/mini.icons" },
    opts = {
      -- fzf_bin = /usr/bin/fzf
      -- each of the following options can also be passed as a function that returns an
      -- options table
      -- e.g., winopts = function() return { ... } end
      -- UI Options
      winopts = {
        -- Open in a split window instead of a floating window
        -- split = "belowright new" -- open a split window below
        -- split = "belowright vsplit" -- open a split window to the right
        -- Only valid when using a float window
        -- (i.e. when 'split' is not defined, default)
        height           = 0.85,            -- window height
        width            = 0.80,            -- window width
        row              = 0.35,            -- window row position (0=top, 1=bottom)
        col              = 0.50,            -- window col position (0=left, 1=right)
        -- border argument passthrough to nvim_open_win()
        -- border           = "rounded",
        border           = "shadow",
        -- Backdrop opacity, 0 is fully opaque, 100 is fully transparent (i.e. disabled)
        backdrop         = 60,
        -- title         = "Title",
        -- title_pos     = "center",        -- 'left', 'center' or 'right'
        -- title_flags   = false,           -- uncomment to disable title flags
        fullscreen       = false,           -- start fullscreen?
        -- enable treesitter highlighting for the main fzf window will only have
        -- effect where grep like results are present, i.e. "file:line:col:text"
        -- due to highlight color collisions will also override `fzf_colors`
        -- set `fzf_colors=false` or `fzf_colors.hl=...` to override
        treesitter       = {
          enabled    = true,
          fzf_colors = { ["hl"] = "-1:reverse", ["hl+"] = "-1:reverse" }
        },
        preview = {
          -- by default, the default preview uses the 'builtin' previewer
          -- override the default previewer
          default        = 'bat',
          -- preview border: accepts both `nvim_open_win`
          -- and fzf values (e.g. "border-top", "none")
          border         = "sharp",
          wrap           = false,           -- preview line wrap (fzf's 'wrap|nowrap')
          hidden         = false,           -- start preview hidden
          vertical       = "down:45%",      -- up|down:size
          horizontal     = "right:60%",     -- right|left:size
          layout         = "flex",          -- horizontal|vertical|flex
          flip_columns   = 100,             -- #cols to switch to horizontal on flex
          -- Only used with the builtin previewer:
          title          = true,            -- preview border title (file/buf)?
          title_pos      = "center",        -- left|center|right, title alignment
          scrollbar      = "float",         -- `false` or string:'float|border'
          -- float:  in-window floating border
          -- border: in-border "block" marker
          scrolloff      = -1,              -- float scrollbar offset from right
          -- applies only when scrollbar = 'float'
          delay          = 10,              -- delay(ms) displaying the preview
          -- prevents lag on fast scrolling
          winopts = {                       -- builtin previewer window options
            number            = true,
            relativenumber    = false,
            cursorline        = true,
            cursorlineopt     = "both",
            cursorcolumn      = false,
            signcolumn        = "no",
            list              = false,
            foldenable        = false,
            foldmethod        = "manual",
          },
          -- native fzf previewers (bat/cat/git/etc)
          -- can also be set to `fun(winopts, metadata)`
        },
        on_create = function()
          -- called once upon creation of the fzf main window
          -- can be used to add custom fzf-lua mappings, e.g:
          --   vim.keymap.set("t", "<C-j>", "<Down>", { silent = true, buffer = true })
        end,
        -- called once _after_ the fzf interface is closed
        -- on_close = function() ... end
      }
      -- Neovim keymaps / fzf binds
      keymap = {
        ["--bind"] = "ctrl-b:page-up",
        ["--bind"] = "ctrl-f:page-down",
        ["--bind"] = "ctrl-j:replace-query+print-query",
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
      -- SPECIFIC COMMAND/PICKER OPTIONS, SEE BELOW
      -- files = { ... },
    },
  },
}
