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
if (lazy ~= nil) then
  lazy.setup({
    spec = { { import = "plugins" } },
    -- Configure any other settings here. See the documentation for more details.
    -- c<M-olorscheme that will be used when installing plugins.
    -- automatically check for plugin updates
    checker = { enabled = true },
    ui = {
      -- a number <1 is a percentage., >1 is a fixed size
      size = { width = 0.8, height = 0.8 },
      wrap = true, -- wrap the lines in the ui
      -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
      border = "none",
      -- The backdrop opacity. 0 is fully opaque, 100 is fully transparent.
      backdrop = 60,
      title = nil, ---@type string only works when border is not "none"
      title_pos = "center", ---@type "center" | "left" | "right"
      -- Show pills on top of the Lazy window
      pills = true, ---@type boolean
      icons = {
        cmd = " ",
        config = "",
        debug = "● ",
        event = " ",
        favorite = " ",
        ft = " ",
        init = " ",
        import = " ",
        keys = " ",
        lazy = "󰒲 ",
        loaded = "●",
        not_loaded = "○",
        plugin = " ",
        runtime = " ",
        require = "󰢱 ",
        source = " ",
        start = " ",
        task = "✔ ",
        list = {
          "●",
          "➜",
          "★",
          "‒",
        },
      },
      -- leave nil, to automatically select a browser depending on your OS.
      -- If you want to use a specific browser, you can define it here
      browser = nil, ---@type string?
      throttle = 1000 / 30, -- how frequently should the ui process render events
      custom_keys = {
        -- You can define custom key maps here. If present, the description will
        -- be shown in the help menu.
        -- To disable one of the defaults, set it to false.

        ["<localleader>l"] = {
          function(plugin)
            require("lazy.util").float_term({ "lazygit", "log" }, {
              cwd = plugin.dir,
            })
          end,
          desc = "Open lazygit log",
        },

        ["<localleader>i"] = {
          function(plugin)
            Util.notify(vim.inspect(plugin), {
              title = "Inspect " .. plugin.name,
              lang = "lua",
            })
          end,
          desc = "Inspect Plugin",
        },

        ["<localleader>t"] = {
          function(plugin)
            require("lazy.util").float_term(nil, {
              cwd = plugin.dir,
            })
          end,
          desc = "Open terminal in plugin dir",
        },
      },
    },
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
      ['<C-@>'] = cmp.mapping.complete(),
      ['<C-g>'] = cmp.mapping.abort(),
      ['<C-q>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      ['<C-j>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources(
      {
        -- { name = "copilot" },
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
        -- { name = "copilot" },
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


  -- Configure which-key
  require("which-key").setup({})


  -- Set a color scheme
  if vim.o.background == "light" then
    vim.cmd("colorscheme dawnfox")
  else
    vim.cmd("colorscheme xcodedark")
  end
end
