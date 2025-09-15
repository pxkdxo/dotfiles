return {
  {
    'nvim-mini/mini.pick',
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
        ["ctrl-z"] = "abort",
        ["ctrl-u"] = "unix-line-discard",
        ["ctrl-f"] = "half-page-down",
        ["ctrl-b"] = "half-page-up",
        ["ctrl-a"] = "beginning-of-line",
        ["ctrl-e"] = "end-of-line",
        ["ctrl-j"] = "replace-query",
        ["ctrl-k"] = "kill-line",
        ["ctrl-o"] = "execute-silent(printf %s {} | { pbcopy || wl-copy || xclip -sel clipboard; })",
        ["ctrl-/"] = "toggle-preview",
        ["ctrl-]"] = "jump-accept",
        ["insert"] = "replace-query",
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
        ["--input-border"] = "line",
      },
      -- fzf_colors = {},  -- Fzf `--color` specification
      -- hls = {},         -- Highlights
      -- previewers = {},  -- Previewers options
      -- files = { ... },
    },
  },
}
