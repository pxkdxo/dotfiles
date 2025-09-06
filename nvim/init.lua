-- ~/.config/nvim/init.lua: NeoViM initializaiton script


-- Load editor options
require("config.options")


-- Is this VSCode?
-- if (vim.g.vscode ~= nil) then
--   return nil
-- end


-- Load plugins
require("config.lazy").setup({
  spec = { { import = "plugins" } },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  -- install = { colorscheme = { "evening" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})


-- Tree Sitter
require('nvim-treesitter.configs').setup({
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
})


-- Setup luasnip lazy loading
require("luasnip.loaders.from_vscode").lazy_load()


-- Setup cmp
local cmp = require('cmp')
cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
      -- For `mini.snippets` users:
      -- local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
      -- insert({ body = args.body }) -- Insert at cursor
      -- cmp.resubscribe({ "TextChangedI", "TextChangedP" })
      -- require("cmp.config").set_onetime({ sources = {} })
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-g>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources(
    {
      { name = "copilot" },
      { name = 'nvim_lsp' },
    }, {
      { name = 'buffer' },
      { name = 'luasnip' }, -- For luasnip users.
    }, {
      { name = 'path' },
      { name = 'cmdline' },
    }
  ),
  view = {
    docs = {
      auto_open = true,
    },
  },
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources(
    {
      { name = 'buffer' },
    }
  ),
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources(
    {
      { name = 'path' },
      { name = 'cmdline' },
    }, {
      { name = 'buffer' },
    }, {
      { name = 'nvim_lsp' },
    }
  ),
  matching = { disallow_symbol_nonprefix_matching = false }
})

-- Setup cmp autopairs completion
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)

-- Set up lspconfig.
local cmp_nvim_lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
-- require('lspconfig')['<YOUR_LSP_SERVER>'].setup {
--   capabilities = cmp_nvim_lsp_capabilities
-- }


-- Trouble FzfLua Actions
local fzf_lua_config = require("fzf-lua.config")
local trouble_fzf_lua_actions = require("trouble.sources.fzf").actions
fzf_lua_config.defaults.actions.files["ctrl-t"] = trouble_fzf_lua_actions.open


-- Enable which-key
require("which-key").setup {}


-- Set a color scheme
if vim.o.background == "dark" then
  vim.cmd("colorscheme rose-pine")
else
  vim.cmd("colorscheme dayfox")
end
