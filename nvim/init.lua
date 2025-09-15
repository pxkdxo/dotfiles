-- ~/.config/nvim/init.lua: Nvim initializaiton script

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = ";"
vim.g.maplocalleader = ","

-- Load editor options
require("config.options")

-- Load plugins
local lazy = require("config.lazy")
if lazy == nil then
  return nil
end

lazy.setup({
  spec = { { import = "plugins" } },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  -- automatically check for plugin updates
  checker = { enabled = true },
  ui = {
    -- a number <1 is a percentage., >1 is a fixed size
    size = { width = 0.8, height = 0.85 },
    wrap = true, -- wrap the lines in the ui
    -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
    border = "none",
    -- The backdrop opacity. 0 is fully opaque, 100 is fully transparent.
    backdrop = 20,
    title = nil, ---@type string only works when border is not "none"
    title_pos = "center", ---@type "center" | "left" | "right"
    -- Show pills on top of the Lazy window
    pills = true, ---@type boolean
    throttle = 1000 / 30, -- how frequently should the ui process render events
  },
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
    ['<PageUp>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<PageDown>'] = cmp.mapping.scroll_docs(4),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-/>'] = function () return cmp.visible() and cmp.mapping.close_docs() or cmp.mapping.open_docs() end,
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-@>'] = cmp.mapping.complete(),
    ['<C-]>'] = cmp.mapping.complete_common_string(),
    ['<C-g>'] = cmp.mapping.abort(),
    ['<C-q>'] = cmp.mapping.abort(),
    ['<C-j>'] = cmp.mapping.confirm({ select = true }),
    ['<C-s>'] = cmp.mapping.confirm({ select = true }),
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
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
      { name = "copilot" },
      { name = 'nvim_lsp' },
    }
  ),
  matching = { disallow_symbol_nonprefix_matching = false }
})


-- Set up lspconfig.
local cmp_nvim_lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
-- require('lspconfig')['<YOUR_LSP_SERVER>'].setup { capabilities = cmp_nvim_lsp_capabilities }


-- Setup cmp autopairs completion
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)

-- Trouble FzfLua Actions
local fzf_lua_config = require("fzf-lua.config")
local trouble_fzf_lua_actions = require("trouble.sources.fzf").actions
fzf_lua_config.defaults.actions.files["ctrl-t"] = trouble_fzf_lua_actions.open


-- Set a color scheme
if vim.o.background == "light" then
  vim.cmd("colorscheme dawnfox")
else
  vim.cmd("colorscheme cyberdream")
end
