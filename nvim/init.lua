-- Load vim options
opt = require("config.options")

-- Load plugins
lazy = require("config.lazy")
lazy.setup({
  spec = { { import = "plugins" } },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "wildcharm" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
require("nightfox").setup({})
require("github-theme").setup({})
require("telescope").setup({})
require("diffview").setup({})
require("nvim-web-devicons").setup{}
require('mini.pick').setup()
require'nvim-treesitter.configs'.setup {
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
  auto_install = true,
  sync_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false
  },
  indent = {
    enable = true
  },
  select = {
    enable = true,
    lookahead = true,
    include_surrounding_whitespace = true
  }
}
require'treesitter-context'.setup({
  -- Enable this plugin (Can be enabled/disabled later via commands)
  enable = true,

  -- Enable multiwindow support.
  multiwindow = false,

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
})
vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

require("fzf-lua").setup({"hide"})

require('neogit').setup {
  -- Hides the hints at the top of the status buffer
  disable_hint = false,
  -- Disables changing the buffer highlights based on where the cursor is.
  disable_context_highlighting = false,
  -- Disables signs for sections/items/hunks
  disable_signs = false,
  -- Offer to force push when branches diverge
  prompt_force_push = true,
  -- Changes what mode the Commit Editor starts in. `true` will leave nvim in normal mode, `false` will change nvim to
  -- insert mode, and `"auto"` will change nvim to insert mode IF the commit message is empty, otherwise leaving it in
  -- normal mode.
  disable_insert_on_commit = "auto",
  -- When enabled, will watch the `.git/` directory for changes and refresh the status buffer in response to filesystem
  -- events.
  filewatcher = {
    interval = 1000,
    enabled = true,
  },
  -- "ascii"   is the graph the git CLI generates
  -- "unicode" is the graph like https://github.com/rbong/vim-flog
  -- "kitty"   is the graph like https://github.com/isakbm/gitgraph.nvim - use https://github.com/rbong/flog-symbols if you don't use Kitty
  graph_style = "unicode",
  -- Show relative date by default. When set, use `strftime` to display dates
  commit_date_format = nil,
  log_date_format = nil,
  -- Used to generate URL's for branch popup action "pull request".
  git_services = {
    ["github.com"] = "https://github.com/${owner}/${repository}/compare/${branch_name}?expand=1",
    ["bitbucket.org"] = "https://bitbucket.org/${owner}/${repository}/pull-requests/new?source=${branch_name}&t=1",
    ["gitlab.com"] = "https://gitlab.com/${owner}/${repository}/merge_requests/new?merge_request[source_branch]=${branch_name}",
    ["azure.com"] = "https://dev.azure.com/${owner}/_git/${repository}/pullrequestcreate?sourceRef=${branch_name}&targetRef=${target}",
  },
  -- Allows a different telescope sorter. Defaults to 'fuzzy_with_index_bias'. The example below will use the native fzf
  -- sorter instead. By default, this function returns `nil`.
  telescope_sorter = function()
    return require("telescope").extensions.fzf.native_fzf_sorter()
  end,
  -- Persist the values of switches/options within and across sessions
  remember_settings = true,
  -- Scope persisted settings on a per-project basis
  use_per_project_settings = true,
  -- Table of settings to never persist. Uses format "Filetype--cli-value"
  ignored_settings = {},
  -- Configure highlight group features
  highlight = {
    italic = true,
    bold = true,
    underline = true
  },
  -- Set to false if you want to be responsible for creating _ALL_ keymappings
  use_default_keymaps = true,
  -- Neogit refreshes its internal state after specific events, which can be expensive depending on the repository size.
  -- Disabling `auto_refresh` will make it so you have to manually refresh the status after you open it.
  auto_refresh = true,
  -- Value used for `--sort` option for `git branch` command
  -- By default, branches will be sorted by commit date descending
  -- Flag description: https://git-scm.com/docs/git-branch#Documentation/git-branch.txt---sortltkeygt
  -- Sorting keys: https://git-scm.com/docs/git-for-each-ref#_options
  sort_branches = "-committerdate",
  -- Default for new branch name prompts
  initial_branch_name = "",
  -- Change the default way of opening neogit
  kind = "tab",
  -- Floating window style 
  floating = {
    relative = "editor",
    width = 0.8,
    height = 0.7,
    style = "minimal",
    border = "rounded",
  },
  -- Disable line numbers
  disable_line_numbers = true,
  -- Disable relative line numbers
  disable_relative_line_numbers = true,
  -- The time after which an output console is shown for slow running commands
  console_timeout = 2000,
  -- Automatically show console if a command takes more than console_timeout milliseconds
  auto_show_console = true,
  -- Automatically close the console if the process exits with a 0 (success) status
  auto_close_console = true,
}
require("bufferline").setup{}

-- Set a color scheme
vim.cmd("colorscheme github_dark")
