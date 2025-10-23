return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = 'master',
    lazy = false,
    build = function (_)
      if vim.fn.exists(":TSUpdate") then
        vim.cmd.TSUpdate()
      end
    end,
    opts = {
      sync_install = false,
      auto_install = true,
      highlight = {
        enable = true,
        disable = { },
        additional_vim_regex_highlighting = false,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<leader>nn",
          node_incremental = "<leader>rn",
          scope_incremental = "<leader>rc",
          node_decremental = "<leader>rm",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          include_surrounding_whitespace = true,
        },
        lsp_interop = {
          enable = true,
          border = "shadow",
          floating_preview_opts = {},
          peek_definition_code = {
            ["<leader>df"] = "@function.outer",
            ["<leader>dF"] = "@class.outer",
          },
        },
      },
      ensure_installed = {
        "bash",
        "c",
        "c_sharp",
        "comment",
        "cpp",
        "css",
        "csv",
        "diff",
        "dockerfile",
        "erlang",
        "fish",
        "fortran",
        "git_config",
        "git_rebase",
        "gitignore",
        "go",
        "gomod",
        "gosum",
        "gpg",
        "groovy",
        "haskell",
        "hcl",
        "helm",
        "html",
        "ini",
        "java",
        "javascript",
        "jinja",
        "jinja_inline",
        "jq",
        "json",
        "kotlin",
        "latex",
        "lua",
        "make",
        "markdown",
        "markdown_inline",
        "nasm",
        "nginx",
        "objdump",
        "pem",
        "perl",
        "php",
        "powershell",
        "printf",
        "python",
        "r",
        "readline",
        "regex",
        "rego",
        "ruby",
        "rust",
        "scala",
        "sql",
        "ssh_config",
        "terraform",
        "typescript",
        "udev",
        "vim",
        "xml",
        "xresources",
        "yaml",
      },
    },
    config = function (_, opts)
      require('nvim-treesitter').setup()
      require('nvim-treesitter.configs').setup(opts)
    end
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      -- Enable this plugin (Can be enabled/disabled later via commands)
      enable = true,
      -- Enable multiwindow support.
      multiwindow = true,
      -- How many lines the window should span. Values <= 0 mean no limit.
      -- Can be '<int>%' like '30%' - to specify percentage of win.height
      max_lines = 0,
      -- Minimum editor window height to enable context. Values <= 0 mean no
      -- limit.
      min_window_height = 0,
      -- Whether to show line numbers
      line_numbers = true,
      -- Maximum number of lines to show for a single context
      multiline_threshold = 20,
      -- Which context lines to discard if `max_lines` is exceeded.
      -- Choices: 'inner', 'outer'
      trim_scope = 'outer',
      -- Line used to calculate context.
      -- Choices: 'cursor', 'topline'
      mode = 'cursor',
      -- Separator between context and content. Should be a single character
      -- string, like '-'. When separator is set, the context will only show
      -- up when there are at least 2 lines above cursorline.
      separator = nil,
      -- The Z-index of the context window
      zindex = 20,
      -- (fun(buf: integer): boolean) return false to disable attaching
      on_attach = nil,
    },
    config = function (_, opts)
      vim.wo.foldmethod = 'expr'
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      require('treesitter-context').setup(opts)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  }
}
