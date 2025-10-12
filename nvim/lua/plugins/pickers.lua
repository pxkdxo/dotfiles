return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    cond = not vim.g.vscode,
    ---@type snacks.Config
    opts = {
      input = { enabled = true },
    },
  },
  {
    "ibhagwan/fzf-lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    cond = not vim.g.vscode,
    cmd = "Fzf",
    opts = {
      -- Base Profile
      "border-fused",
      -- UI Options
      winopts = {
        -- split = "belowright new" -- open a split window below
        -- split = "belowright vsplit" -- open a split window to the right
        -- or, when using a floating window
        height           = 0.85,            -- window height
        width            = 0.80,            -- window width
        row              = 0.35,            -- window row position (0=top, 1=bottom)
        col              = 0.50,            -- window col position (0=left, 1=right)
        backdrop         = 65,
        fullscreen       = false,
        treesitter       = {
          enabled    = true,
          fzf_colors = { ["hl"] = "-1:reverse", ["hl+"] = "-1:reverse" }
        },
        preview = {
          layout         = "flex",          -- horizontal|vertical|flex
          scrolloff      = -1,              -- float scrollbar offset from right
        },
        on_create = function()
          vim.keymap.set("t", "<C-j>", "<Down>", { silent = true, buffer = true })
        end,
      },
      keymap = {
        ["shift-up"] = "first",
        ["shift-down"] = "last",
        ["alt-left"] = "backward-word",
        ["alt-right"] = "forward-word",
        ["ctrl-b"] = "page-up",
        ["ctrl-f"] = "page-down",
        ["ctrl-\\"] = "bg-cancel",
        ["ctrl-j"] = "accept-or-print-query",
        ["ctrl-s"] = "replace-query",
        ["insert"] = "replace-query",
        ["ctrl-/"] = "toggle-preview",
        ["ctrl-]"] = "jump-accept",
        ["ctrl-o"] = "execute-silent(printf %s {} | { pbcopy || wl-copy || xclip -sel clipboard; })",
        ["ctrl-z"] = "abort",
      },
      --actions = {},
      fzf_opts = {
        ["--ansi"]   = true,
        ["--style"]  = "full",
        ["--layout"] = "reverse",
        ["--tmux"]   = "center,80%,60%",
        ["--border"] = "sharp",
        ["--input-border"] = "line",
        ["--header-border"] = "line",
        ["--preview-border"] = "sharp",
        ["--color"]  = "dark,fg:5,fg+:1,hl:3:bold,hl+:3:bold,bg:-1,bg+:-1:bold,pointer:4:bold,border:3,query:-1,prompt:4:bold,input-border:3,header:4,header-border:3,footer:6,footer-border:3,info:-1:dim,gutter:-1:bold",
        ["--prompt"] = "> ",
        ["--info"]   = "inline-right",
      },
      -- fzf_colors = {},  -- Fzf `--color` specification
      -- hls = {},         -- Highlights
      -- previewers = {},  -- Previewers options
    },
  },
}
