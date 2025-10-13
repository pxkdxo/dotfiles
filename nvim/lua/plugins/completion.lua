return {
  {
    'windwp/nvim-autopairs',
    cond = not vim.g.vscode,
    event = "InsertEnter",
    opts = {
      fast_wrap = {
        chars = { '{', '[', '(', '"', "'" },
        pattern = [=[[%'%"%>%]%)%}%,]]=],
        end_key = '$',
        before_key = 'h',
        after_key = 'l',
        cursor_pos_before = true,
        keys = 'qwertyuiopzxcvbnmasdfghjkl',
        manual_position = true,
        highlight = 'Search',
        highlight_grey='Comment'
      },
    }
  },
  {
    'hrsh7th/cmp-nvim-lsp',
    cond = not vim.g.vscode,
  },
  {
    'hrsh7th/cmp-nvim-lua',
    cond = not vim.g.vscode,
  },
  {
    'hrsh7th/cmp-buffer',
    cond = not vim.g.vscode,
  },
  {
    'hrsh7th/cmp-path',
    cond = not vim.g.vscode,
  },
  {
    'hrsh7th/cmp-cmdline',
    cond = not vim.g.vscode,
  },
  {
    'hrsh7th/nvim-cmp',
    cond = not vim.g.vscode,
    opts = {
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        end,
      },
      view = {
        docs = {
          auto_open = true,
        },
      },
    },
    config = function (_, opts)
      local cmp = require('cmp')
      opts.window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      }
      opts.mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<PageUp>'] = cmp.mapping.scroll_docs(-4),
        ['<PageDown>'] = cmp.mapping.scroll_docs(4),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-s>'] = cmp.mapping.complete_common_string(),
        ['<C-@>'] = cmp.mapping.complete(),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<Tab>'] = cmp.mapping.confirm({ select = true }),
        ['<C-j>'] = cmp.mapping.confirm({ select = false }),
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
        ['<C-g>'] = cmp.mapping.abort(),
      })
      opts.sources = cmp.config.sources(
        {
          { name = "copilot" },
          { name = 'nvim_lsp' },
        }, {
          { name = 'buffer' },
          { name = 'luasnip' }, -- For luasnip users.
        }, {
          { name = 'path' },
        }
      )
      cmp.setup(opts)
      cmp.setup.cmdline(
        { '/', '?' },
        {
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources(
            { { name = 'buffer' }, }
          ),
        }
      )
      cmp.setup.cmdline(
        {':'},
        {
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources(
            {
              { name = 'cmdline' },
              { name = 'path' },
            }
          ),
          matching = { disallow_symbol_nonprefix_matching = false }
        }
      )
      cmp.event:on(
        'confirm_done',
        require('nvim-autopairs.completion.cmp').on_confirm_done()
      )
    end
  },
  {
    'saadparwaiz1/cmp_luasnip',
    cond = not vim.g.vscode,
  },
}
