return {
  {
    "nvim-treesitter/nvim-treesitter",
    cond = true,
    branch = "main",
    lazy = false, -- `main` forbids lazy-loading (README)
    build = ":TSUpdate",
    config = function ()
      -- Explicit parser list. main-branch tiers are misleading: `stable` is only
      -- 7 hand-picked parsers, while ~everything useful (markdown, lua, go, …)
      -- sits in the 315-parser `unstable` tier. Pinning an explicit list keeps
      -- boot predictable and matches the pre-migration coverage + some extras.
      require("nvim-treesitter").install({
        "awk",             "bash",            "bibtex",          "c",
        "c_sharp",         "clojure",         "cmake",           "comment",
        "cpp",             "css",             "csv",             "dart",
        "diff",            "dockerfile",      "elixir",          "erlang",
        "fish",            "fortran",         "git_config",      "git_rebase",
        "gitattributes",   "gitcommit",       "gitignore",       "go",
        "gomod",           "gosum",           "gpg",             "graphql",
        "groovy",          "haskell",         "hcl",             "helm",
        "html",            "ini",             "java",            "javascript",
        "jinja",           "jinja_inline",    "jq",              "jsdoc",
        "json",            "just",            "kotlin",          "latex",
        "lua",             "luadoc",          "luap",            "make",
        "markdown",        "markdown_inline", "nasm",            "nginx",
        "ninja",           "nix",             "objdump",         "pem",
        "perl",            "php",             "powershell",      "printf",
        "proto",           "python",          "query",           "r",
        "readline",        "regex",           "rego",            "requirements",
        "rst",             "ruby",            "rust",            "scala",
        "sql",             "ssh_config",      "swift",           "terraform",
        "tmux",            "toml",            "tsx",             "typescript",
        "udev",            "vim",             "vimdoc",          "xml",
        "xresources",      "yaml",            "zig",
      })

      -- Enable highlight / folds for any filetype that has a parser available.
      -- Wrapped in pcall because vim.treesitter.start() throws when a filetype
      -- lacks a parser (e.g., `help`, `man`, proprietary formats).
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter_start", { clear = true }),
        callback = function (args)
          pcall(vim.treesitter.start, args.buf)
        end,
        desc = "Enable treesitter highlighting when a parser is available",
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    cond = true,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      enable = true,
      multiwindow = true,
      max_lines = 0,
      min_window_height = 0,
      line_numbers = true,
      multiline_threshold = 20,
      trim_scope = 'outer',
      mode = 'cursor',
      separator = nil,
      zindex = 20,
      on_attach = nil,
    },
    config = function (_, opts)
      require('treesitter-context').setup(opts)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    cond = true,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "VeryLazy",
    config = function ()
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true,
          include_surrounding_whitespace = true,
        },
        move = { set_jumps = true },
      })

      local select     = require("nvim-treesitter-textobjects.select")
      local move       = require("nvim-treesitter-textobjects.move")
      local swap       = require("nvim-treesitter-textobjects.swap")
      local repeatable = require("nvim-treesitter-textobjects.repeatable_move")

      for lhs, query in pairs({
        ["af"] = { "@function.outer",    "around function" },
        ["if"] = { "@function.inner",    "inside function" },
        ["ac"] = { "@class.outer",       "around class" },
        ["ic"] = { "@class.inner",       "inside class" },
        ["aa"] = { "@parameter.outer",   "around argument" },
        ["ia"] = { "@parameter.inner",   "inside argument" },
        ["al"] = { "@loop.outer",        "around loop" },
        ["il"] = { "@loop.inner",        "inside loop" },
        ["ao"] = { "@conditional.outer", "around conditional" },
        ["io"] = { "@conditional.inner", "inside conditional" },
      }) do
        vim.keymap.set({ "x", "o" }, lhs, function ()
          select.select_textobject(query[1], "textobjects")
        end, { desc = query[2] })
      end

      local function mv(lhs, fn, query, desc)
        vim.keymap.set({ "n", "x", "o" }, lhs, function () fn(query, "textobjects") end, { desc = desc })
      end
      mv("]f", move.goto_next_start,     "@function.outer", "Next function start")
      mv("]c", move.goto_next_start,     "@class.outer",    "Next class start")
      mv("]F", move.goto_next_end,       "@function.outer", "Next function end")
      mv("]C", move.goto_next_end,       "@class.outer",    "Next class end")
      mv("[f", move.goto_previous_start, "@function.outer", "Previous function start")
      mv("[c", move.goto_previous_start, "@class.outer",    "Previous class start")
      mv("[F", move.goto_previous_end,   "@function.outer", "Previous function end")
      mv("[C", move.goto_previous_end,   "@class.outer",    "Previous class end")

      vim.keymap.set("n", "<M-j>", function () swap.swap_next("@parameter.inner") end,     { desc = "Swap parameter with next" })
      vim.keymap.set("n", "<M-k>", function () swap.swap_previous("@parameter.inner") end, { desc = "Swap parameter with previous" })

      -- Make textobject move/swap motions repeatable via ; and , (like native f/t).
      vim.keymap.set({ "n", "x", "o" }, ";", repeatable.repeat_last_move,          { desc = "Repeat last treesitter move" })
      vim.keymap.set({ "n", "x", "o" }, ",", repeatable.repeat_last_move_opposite, { desc = "Repeat last treesitter move (opposite)" })
    end,
  },
}
