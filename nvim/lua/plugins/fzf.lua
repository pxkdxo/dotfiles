return {
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
          ["shift-up"] = "first",
          ["shift-down"] = "last",
          ["alt-left"] = "backward-word",
          ["alt-right"] = "forward-word",
          ["ctrl-b"] = "page-up",
          ["ctrl-f"] = "page-down",
          ["ctrl-\\"] = "bg-cancel",
          ["ctrl-s"] = "replace-query",
          ["insert"] = "replace-query",
          ["ctrl-/"] = "toggle-preview",
          ["ctrl-]"] = "jump-accept",
          ["ctrl-o"] = "execute-silent(printf %s {} | { pbcopy || wl-copy || xclip -sel clipboard; })",
          ["ctrl-z"] = "abort",
        },
      },
      fzf_opts = {
        ["--ansi"]   = true,
        ["--style"]  = "full",
        ["--layout"] = "reverse",
        ["--tmux"]   = "center,80%,65%",
        ["--border"] = "sharp",
        ["--input-border"] ="line",
        ["--header-border"] = "line",
        ["--preview-border"] = "sharp",
        ["--color"]  = "dark,fg:5,fg+:1:bold,hl:3,hl+:3:bold,bg:-1,bg+:-1:bold,pointer:2:bold,border:3,query:-1:regular,prompt:2:bold,input-border:3,header:2,header-border:3,footer:6,footer-border:3,info:-1:dim,gutter:-1:bold",
        ["--prompt"] = "> ",
        ["--info"]   = "inline-right",
      },
    },
  },
}
