return {
  {
    'zbirenbaum/copilot-cmp',
    dependencies = {
      'zbirenbaum/copilot.lua'
    },
    opts = {},
  },
  {
    'saadparwaiz1/cmp_luasnip',
    dependencies = {
      'L3MON4D3/LuaSnip',
    },
  },
  {
    "PaterJason/cmp-conjure",
    dependencies = { 'hrsh7th/nvim-cmp' },
    lazy = true,
  },
  {
    "petertriho/cmp-git",
    dependencies = { 'hrsh7th/nvim-cmp' },
    opts = {},
    -- init = function()
    --   table.insert(require("cmp").get_config().sources, { name = "git" })
    -- end
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-buffer', -- Buffer completions
      'hrsh7th/cmp-cmdline', -- Cmdline completions
      'hrsh7th/cmp-path', -- Path completions
      'hrsh7th/cmp-nvim-lsp', -- LSP completions
      'hrsh7th/cmp-nvim-lua', -- Neovim Lua API completions
      'hrsh7th/cmp-nvim-lsp-document-symbol',
      'folke/lazydev.nvim', -- LazyVim types and completions
      'L3MON4D3/LuaSnip', -- Snippet engine
      "PaterJason/cmp-conjure", -- Conjure
      'saadparwaiz1/cmp_luasnip', -- Snippet completions
      'zbirenbaum/copilot-cmp', -- GitHub Copilot completions
      'windwp/nvim-autopairs', -- Autopairs trigger
      'nvim-mini/mini.icons', -- Completion entry icons
    },
    opts = {
      experimental = { ghost_text = false },
    },
    config = function (_, opts)
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      local unpack = unpack or table.unpack
      local cursor_prefix_is_whitespace = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        local text = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
        return col == 0 or text:sub(col, col):match("%s") ~= nil
      end
      opts = opts or {}
      opts.snippet = { expand = function(args) luasnip.lsp_expand(args.body) end }
      opts.sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "nvim_lua" },
        { name = "lazydev"  },
        { name = "conjure"  },
      },
      {
        { name = "copilot"       },
        { name = "codecompanion" },
        { name = "git" },
        { name = "luasnip" },
        { name = "buffer"  },
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
        format = function(_, vim_item)
          local name = vim_item.kind
          local icon, hl = MiniIcons.get("lsp", name)
          vim_item.kind = " " .. (icon or "") .. " "
          vim_item.kind_hl_group = hl
          vim_item.menu = name and ("    (" .. name .. ")") or "<?>"
          return vim_item
        end,
      }
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
        ['<Tab>'] = cmp.mapping(function (fallback)
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
          if not cmp.visible() then
            fallback()
          elseif #cmp.get_entries() > 0 then
            cmp.select_prev_item()
          end
        end, { "i", "s" }),
      })
      -- Set up cmp
      cmp.setup(opts)
      cmp.setup.cmdline(
        { '/', '?' },
        {
          mapping = cmp.mapping.preset.cmdline({
            ['<C-]>'] = vim.schedule_wrap(function (fallback)
              if cmp.visible() then
                cmp.complete_common_string()
              else
                fallback()
              end
            end),
          }),
          sources = cmp.config.sources({
            { name = 'nvim_lsp_document_symbol' },
            { name = 'buffer' },
          }),
        }
      )
      cmp.setup.cmdline(
        {':'},
        {
          mapping = cmp.mapping.preset.cmdline({
            ['<CR>'] = cmp.mapping.confirm({ select = false }),
            ['<C-]>'] = vim.schedule_wrap(function (fallback)
              if cmp.visible() then
                cmp.complete_common_string()
              else
                fallback()
              end
            end),
            ['<Tab>'] = cmp.mapping(function (_)
              if cmp.visible() then
                local n_entries = #cmp.get_entries()
                if n_entries == 1 then
                  cmp.confirm({ select = true })
                else
                  cmp.select_next_item()
                end
              else
                cmp.complete()
                local n_entries = #cmp.get_entries()
                if n_entries == 1 then
                  cmp.confirm({ select = true })
                elseif n_entries > 1 then
                  cmp.complete_common_string()
                end
              end
            end),
            ['<S-Tab>'] = cmp.mapping(function (fallback)
              if not cmp.visible() then
                fallback()
              elseif #cmp.get_entries() > 0 then
                cmp.select_prev_item()
              end
            end),
          }),
          sources = cmp.config.sources({
            { name = 'cmdline' }, { name = 'path', option = { trailing_slash = true } }
          },
          {
            { name = 'buffer'  }
          }),
          -- matching = { disallow_symbol_nonprefix_matching = false },
        }
      )
      -- Trigger autopairs on confirmation of a completion
      cmp.event:on(
        'confirm_done',
        require('nvim-autopairs.completion.cmp').on_confirm_done()
      )
      -- Extra LSP config
      vim.lsp.config("*", { capabilities = require("cmp_nvim_lsp").default_capabilities() })
    end
  },
}
