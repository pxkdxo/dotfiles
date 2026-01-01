return {
  {
    'nvim-telescope/telescope.nvim',
    cond = vim.g.vscode == nil,
    tag = 'v0.2.0',
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    opts = {
      extensions = {
        fzf = {
          fuzzy = true,                    -- false will only do exact matching
          override_generic_sorter = true,  -- override the generic sorter
          override_file_sorter = true,     -- override the file sorter
        }
      }
    },
    config = function (_, opts)
      local telescope = require('telescope')
      telescope.setup(opts)
      telescope.load_extension('fzf')
    end,
  },
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    cond = vim.g.vscode == nil and vim.fn.executable("make") == 1,
    build = 'make'
  },
  {
    "ibhagwan/fzf-lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    cmd = "Fzf",
    config = function (_, opts)
      require("fzf-lua").setup(opts)
      vim.cmd.FzfLua("setup_fzfvim_cmds")
    end,
    opts = {
      -- Base Profile
      { "default", "ivy", "border-fused", "hide" },
      -- UI Options
      winopts = {
        -- split = "belowright new" -- open a split window below
        -- split = "belowright vsplit" -- open a split window to the right
        -- or, when using a floating window
        height           = 0.85,            -- window height
        width            = 0.70,            -- window width
        row              = 0.40,            -- window row position (0=top, 1=bottom)
        col              = 0.50,            -- window col position (0=left, 1=right)
        backdrop         = 65,
        fullscreen       = false,
        preview = {
          layout         = "flex",          -- horizontal|vertical|flex
          scrolloff      = -1,              -- float scrollbar offset from right
        },
      },
      keymap = {
        fzf = {
          ["enter"] = "accept",
          ["ctrl-m"] = "accept",
          ["shift-up"] = "first",
          ["shift-down"] = "last",
          ["alt-left"] = "backward-word",
          ["alt-right"] = "forward-word",
          ["ctrl-z"] = "abort",
          ["ctrl-b"] = "page-up",
          ["ctrl-f"] = "page-down",
          ["ctrl-\\"] = "bg-cancel",
          ["ctrl-s"] = "replace-query",
          ["insert"] = "replace-query",
          ["ctrl-/"] = "toggle-preview",
          ["ctrl-]"] = "jump",
          ["ctrl-o"] = "execute-silent(printf %s {} | { pbcopy || wl-copy || xclip -sel clipboard; })",
        },
      },
      fzf_opts = {
        ["--ansi"] = true,
        ["--layout"] = "reverse",
        ["--tmux"] = "center,80%,65%",
        ["--border"] = "sharp",
        ["--color"] = "dark,fg:5,fg+:1:bold,hl:3,hl+:3:bold,bg:-1,bg+:-1:bold,pointer:2:bold,border:3,query:-1:regular,prompt:2:bold,input-border:3,header:2,header-border:3,footer:6,footer-border:3,info:-1:dim,gutter:-1:bold",
        ["--prompt"] = "> ",
      },
    },
  },
}
