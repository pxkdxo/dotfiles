return {
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-buffer', -- Buffer completions
      'hrsh7th/cmp-cmdline', -- Cmdline completions
      'hrsh7th/cmp-path', -- Path completions
      'hrsh7th/cmp-nvim-lsp', -- LSP completions
      'hrsh7th/cmp-nvim-lua', -- Neovim Lua API completions
      'folke/lazydev.nvim', -- LazyVim types and completions
      'L3MON4D3/LuaSnip', -- Snippet engine
      'saadparwaiz1/cmp_luasnip', -- Snippet completions
      'zbirenbaum/copilot-cmp', -- GitHub Copilot completions
      'onsails/lspkind.nvim', -- LSP completion icons
      'windwp/nvim-autopairs', -- Autopairs trigger
    },
    opts = {
      experimental = { ghost_text = false },
    },
    config = function (_, opts)
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      local lspkind = require('lspkind')
      local unpack = unpack or table.unpack
      local cursor_prefix_is_whitespace = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        local text = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
        return col == 0 or text:sub(col, col):match("%s") ~= nil
      end
      opts = opts or {}
      opts.snippet = { expand = function(args) luasnip.lsp_expand(args.body) end }
      opts.sources = cmp.config.sources(
        {
          { name = "copilot"  },
          { name = "nvim_lsp" },
          { name = "nvim_lua" },
          { name = "lazydev"  },
        },
        {
          { name = "luasnip"  },
          { name = "buffer"   },
        }
      )
      opts.mapping = cmp.mapping.preset.insert({
        ['<C-q'] = cmp.mapping.abort(),
        ['<C-@>'] = cmp.mapping.complete(),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<PageUp>'] = cmp.mapping.scroll_docs(-4),
        ['<PageDown>'] = cmp.mapping.scroll_docs(4),
        ['<C-g>'] = function()
          if cmp.visible_docs() then
            cmp.close_docs()
          else
            cmp.open_docs()
          end
        end,
        ['<C-]>'] = vim.schedule_wrap(function(fallback)
          if cmp.visible() then
            return cmp.complete_common_string()
          end
          fallback()
        end),
        ['<CR>'] = {
          i = function(fallback)
            if cmp.visible() and cmp.get_active_entry() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
            else
              fallback()
            end
          end,
          s = cmp.mapping.confirm({ select = true }),
          c = cmp.mapping.confirm({ select = false }),
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            if #cmp.get_entries() == 1 then
              cmp.confirm({ select = true })
            else
              cmp.select_next_item()
            end
          elseif luasnip.locally_jumpable(1) then
            luasnip.jump(1)
          elseif cursor_prefix_is_whitespace() then
            fallback()
          else
            cmp.complete()
            if #cmp.get_entries() == 1 then
              cmp.confirm({ select = true })
            end
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            if #cmp.get_entries() == 1 then
              cmp.confirm({ select = true })
            else
              cmp.select_prev_item()
            end
          elseif luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      })
      opts.window = opts.window or {}
      opts.window.completion = cmp.config.window.bordered({
        border = "rounded",
        col_offset = -3,
        scrollbar = false,
        scrolloff = 1,
        side_padding = 0,
        winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",

      })
      opts.window.documentation = cmp.config.window.bordered({
        border = "rounded",
        scrollbar = false,
        scrolloff = 1,
        side_padding = 1,
      })
      opts.formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
          local kind = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = {
              menu = function() return math.max(math.floor(0.40 * vim.o.columns), 40) end, -- leading text (labelDetails)
              abbr = function() return math.max(math.floor(0.40 * vim.o.columns), 40) end, -- actual suggestion item
            },
            ellipsis_char = '',
            symbol_map = { Copilot = "" }
          })(entry, vim_item)
          local strings = vim.split(kind.kind, "%s", { trimempty = true })
          kind.kind = " " .. (strings[1] or "") .. " "
          kind.menu = "    (" .. (strings[2] or "") .. ")"
          return kind end,
      }
      -- Set up cmp
      cmp.setup(opts)
      cmp.setup.cmdline(
        { '/', '?' },
        {
          mapping = cmp.mapping.preset.cmdline({
            ['<C-]>'] = vim.schedule_wrap(function(fallback)
              if cmp.visible() then return cmp.complete_common_string() end
              return fallback()
            end),
          }),
          sources = cmp.config.sources({ { name = 'buffer' } })
        }
      )
      cmp.setup.cmdline(
        {':'},
        {
          mapping = cmp.mapping.preset.cmdline({
            ['<CR>'] = cmp.mapping.confirm({ select = false }),
            ['<Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                local n_entries = #cmp.get_entries()
                if n_entries > 1 then
                  return cmp.select_next_item()
                elseif n_entries == 1 then
                  return cmp.confirm({ select = true })
                end
                return fallback()
              end
              cmp.complete()
              if #cmp.get_entries() > 1 then
                return cmp.complete_common_string()
              end
              return cmp.confirm({ select = true })
            end),
            ['<S-Tab>'] = function()
              if cmp.visible() then
                local n_entries = #cmp.get_entries()
                if n_entries > 1 then
                  return cmp.select_prev_item()
                elseif n_entries == 1 then
                  return cmp.confirm({ select = true })
                end
                return fallback()
              end
              cmp.complete()
              if #cmp.get_entries() > 1 then
                return cmp.complete_common_string()
              end
              return cmp.confirm({ select = true })
            end,
            ['<C-]>'] = vim.schedule_wrap(function(fallback)
              if cmp.visible() then return cmp.complete_common_string() end
              return fallback()
            end),
          }),
          sources = cmp.config.sources(
            { { name = 'cmdline' }, { name = 'path' } },
            { { name = 'buffer'  } }
          ),
          -- matching = { disallow_symbol_nonprefix_matching = false },
        }
      )
      -- Trigger autopairs on confirmation of a completion
      cmp.event:on(
        'confirm_done',
        require('nvim-autopairs.completion.cmp').on_confirm_done()
      )
      -- Extra LSP config
      -- vim.lsp.config("*", { capabilities = require("cmp_nvim_lsp").default_capabilities() })
    end
  },
  {
    'saadparwaiz1/cmp_luasnip',
    dependencies = {
      'L3MON4D3/LuaSnip',
    },
  },
  {
    'zbirenbaum/copilot-cmp',
    dependencies = { 'zbirenbaum/copilot.lua' },
    opts = {},
  },
  {
    'onsails/lspkind.nvim',
    opts = {}
  },
}
