return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons'
    },
    opts = {
      options = {
        theme = "auto", -- "auto" will set the theme dynamically based on the colorscheme
      },
    }
  },
  {
    'akinsho/bufferline.nvim',
    version = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons'
    },
    opts = {
      options = {
        themable = true,
        diagnostics = true,
        color_icons = true,
        show_buffer_icons = true,
        --- count is an integer representing total count of errors
        --- level is a string "error" | "warning"
        --- this should return a string
        --- Don't get too fancy as this function will be executed a lot
        diagnostics_indicator = function(count, level)
          local icon = level:match("error") and "" or ""
          return " " .. icon .. count
        end,
      }
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    opts = {
      indent = {
        char = "▎",
      },
      scope = {
        enabled = true
      }
    },
  },
  {
    'kevinhwang91/nvim-bqf',
    ft = 'qf',
    opts = {},
  },
  {
    'RRethy/vim-illuminate',
    event = "InsertEnter",
    opts = {
      bind = true,
      handler_opts = {
        border = "rounded",
      },
      hint_prefix = "✭ ",
    },
    config = function (_, opts)
      require('illuminate').configure(opts)
    end
  },
  {
    "goolord/alpha-nvim",
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      local alpha = require("alpha")
      local theme = require("alpha.themes.startify")
      theme.file_icons = theme.file_icons or {}
      theme.file_icons.provider = "devicons"
      alpha.setup(theme.config)
    end,
  },
  {
    'kevinhwang91/nvim-ufo',
    dependencies = {
      'kevinhwang91/promise-async'
    },
    opts = {
      open_fold_hl_timeout = 150,
      preview = {
        win_config = {
          border = 'rounded',
          winhighlight = 'Normal:Folded',
          winblend = 40,
          maxheight = 25,
        },
        mappings = {
          scrollU = '<C-u>',
          scrollD = '<C-d>',
          jumpTop = '<Home>',
          jumpBot = '<End>',
        }
      },
      provider_selector = function(_, _, _)
        return {'treesitter', 'indent'}
      end,
    },
    config = function (_, opts)
      -- Load ufo
      local ufo = require('ufo')

      -- Set nvim folding options
      vim.o.foldcolumn = '1' -- '0' is not bad
      vim.o.foldlevel = 99 -- Using ufo provider need a large value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      -- Copy the virtual text of a folded line truncated to a given width
      local function _fold_handler_rec(orig_text, new_text, max_width, new_width, truncate, prev_index)
        local index, chunk = next(orig_text, prev_index)
        if index ~= nil and chunk ~= nil then
          local chunk_text = chunk[1]
          local chunk_hl_group = chunk[2]
          local chunk_width = vim.fn.strdisplaywidth(chunk_text)
          if new_width + chunk_width < max_width then
            table.insert(new_text, {chunk_text, chunk_hl_group})
            new_width = new_width + chunk_width
            return _fold_handler_rec(orig_text, new_text, max_width, new_width, truncate, index)
          end
          chunk_text = truncate(chunk_text, max_width - new_width)
          chunk_width = vim.fn.strdisplaywidth(chunk_text)
          table.insert(new_text, {chunk_text, chunk_hl_group})
          new_width = new_width + chunk_width
        end
        return new_text, new_width
      end

      -- Custom fold handler
      local function fold_handler(virt_text, lnum, end_lnum, width, truncate)
        local suffix = (' 󰁂 +%d '):format(end_lnum - lnum)
        local target_width = width - vim.fn.strdisplaywidth(suffix)
        local result_text, result_width = _fold_handler_rec(virt_text, {}, target_width, 0, truncate)
        local spaces = (' '):rep(target_width - result_width)
        table.insert(result_text, {suffix .. spaces, 'MoreMsg'})
        return result_text
      end

      -- Set the fold handler
      opts.fold_virt_text_handler = fold_handler

      -- Setup ufo
      ufo.setup(opts)

      -- Set key mappings
      vim.keymap.set('n', 'zR', ufo.openAllFolds)
      vim.keymap.set('n', 'zM', ufo.closeAllFolds)
      vim.keymap.set('n', 'zK', function()
        if not ufo.peekFoldedLinesUnderCursor() then
          vim.lsp.buf.hover()
        end
      end)
    end,
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      -- background_colour = "NotifyBackground",
      background_colour = "CursorColumn",
      level = 2,
      minimum_width = 24,
      -- fps = 60,
      render = "default",
      -- stages = "fade",
      timeout = 3500,
      top_down = false,
      time_formats = {
        notification = "%A, %X",
        notification_history = "%F %T%z"
      },
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    cond = false,
    dependencies = {
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    },
    opts = {
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
      lsp = {
        -- disable lsp loading progress view
        progress = {
          enabled = false,
        },
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
        },
        hover = {
          enabled = true,
          ---@type NoiceViewOptions
          opts = {},
        },
        signature = {
          enabled = false,
          auto_open = {
            -- enabled = true,
            -- trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
            -- luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
            -- throttle = 50, -- Debounce lsp signature help request by 50ms
          },
          ---@type NoiceViewOptions
          opts = {},
        },
        documentation = {
          view = "hover",
          ---@type NoiceViewOptions
          opts = {
            scrollbar = false,
            border = { style = "rounded" },
            win_options = { concealcursor = "n", conceallevel = 3 },
          },
        },
      },
      cmdline = {
        enabled = true, -- enables the Noice cmdline UI
        view = "cmdline_popup", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
        format = {
          -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
          -- view: (default is cmdline view)
          -- opts: any options passed to the view
          -- icon_hl_group: optional hl_group for the icon
          -- title: set to anything or empty string to hide
          cmdline = { pattern = "^:", icon = "", lang = "vim" },
          search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
          search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
          filter = { pattern = "^:%s*!", icon = "", lang = "bash" },
          lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
          help = { pattern = "^:%s*he?l?p?%s+", icon = "󰋖" },
          input = { view = "cmdline_input", icon = "󰥻 " }, -- Used by input()
        },
      },
    },
    config = function (_, opts)
      local noice = require('noice')
      local noice_lsp = require('noice.lsp')

      -- Set up noice
      noice.setup(opts)

      -- Scroll inside LSP hover docs
      vim.keymap.set({ "n", "i", "s" }, "<C-b>", function()
        if not noice_lsp.scroll(-4) then
          return "<C-b>"
        end
      end, { silent = true, expr = true })
      vim.keymap.set({ "n", "i", "s" }, "<C-f>", function()
        if not noice_lsp.scroll(4) then
          return "<C-f>"
        end
      end, { silent = true, expr = true })
      vim.keymap.set({ "n", "i", "s" }, "<C-u>", function()
        if not noice_lsp.scroll(-4) then
          return "<C-u>"
        end
      end, { silent = true, expr = true })
      vim.keymap.set({ "n", "i", "s" }, "<C-d>", function()
        if not noice_lsp.scroll(4) then
          return "<C-d>"
        end
      end, { silent = true, expr = true })
    end,
  },
}
