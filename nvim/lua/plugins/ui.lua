return {
  {
    'nvim-lualine/lualine.nvim',
    cond = vim.g.vscode == nil,
    dependencies = {
      "echasnovski/mini.icons",
      "folke/noice.nvim",
    },
    opts = function()
      local utils = require("core.utils")
      local copilot_colors = {
        [""] = utils.get_hlgroup("Comment"),
        ["Normal"] = utils.get_hlgroup("Comment"),
        ["InProgress"] = utils.get_hlgroup("DiagnosticInfo"),
        ["Warning"] = utils.get_hlgroup("DiagnosticWarn"),
        ["Error"] = utils.get_hlgroup("DiagnosticHint"),
      }
      local filetype_map = {
        lazy = { name = "lazy.nvim", icon = "💤" },
        minifiles = { name = "minifiles", icon = "🗂️ " },
        snacks_terminal = { name = "terminal", icon = "🐚" },
        mason = { name = "mason", icon = "🔨" },
        snacks_picker_input = { name = "picker", icon = "🔍" },
        ["copilot-chat"] = { name = "copilot", icon = "🤖" },
      }
      return {
        options = {
          component_separators = { left = " ", right = " " },
          section_separators = { left = " ", right = " " },
          theme = "auto",
          globalstatus = true,
          disabled_filetypes = { statusline = { "dashboard", "alpha" } },
        },
        sections = {
          lualine_a = {
            {
              "mode",
              icon = "",
              fmt = function(mode)
                return mode:lower()
              end,
            },
          },
          lualine_b = { { "branch", icon = "" } },
          lualine_c = {
            {
              "diagnostics",
              symbols = {
                error = " ",
                warn = " ",
                info = " ",
                hint = " ",
              },
            },
            {
              function()
                local devicons = require("nvim-web-devicons")
                local ft = vim.bo.filetype
                local icon
                if filetype_map[ft] then
                  return " " .. filetype_map[ft].icon
                end
                if icon == nil then
                  icon = devicons.get_icon(vim.fn.expand("%:t"))
                end
                if icon == nil then
                  icon = devicons.get_icon_by_filetype(ft)
                end
                if icon == nil then
                  icon = " 󰈤"
                end

                return icon .. " "
              end,
              color = function()
                local _, hl = require("nvim-web-devicons").get_icon(vim.fn.expand("%:t"))
                if hl then
                  return hl
                end
                return utils.get_hlgroup("Normal")
              end,
              separator = "",
              padding = { left = 0, right = 0 },
            },
            {
              "filename",
              padding = { left = 0, right = 0 },
              fmt = function(name)
                if filetype_map[vim.bo.filetype] then
                  return filetype_map[vim.bo.filetype].name
                else
                  return name
                end
              end,
            },
            {
              function()
                local buffer_count = require("core.utils").get_buffer_count()

                return "+" .. buffer_count - 1 .. " "
              end,
              cond = function()
                return require("core.utils").get_buffer_count() > 1
              end,
              color = utils.get_hlgroup("Operator", nil),
              padding = { left = 0, right = 1 },
            },
            {
              function()
                local tab_count = vim.fn.tabpagenr("$")
                if tab_count > 1 then
                  return vim.fn.tabpagenr() .. " of " .. tab_count
                end
              end,
              cond = function()
                return vim.fn.tabpagenr("$") > 1
              end,
              icon = "󰓩",
              color = utils.get_hlgroup("Special", nil),
            },
            {
              function()
                return require("nvim-navic").get_location()
              end,
              cond = function()
                return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
              end,
              color = utils.get_hlgroup("Comment", nil),
            },
          },
          lualine_x = {
            {
              ---@diagnostic disable: undefined-field
              require("noice").api.status.mode.get,
              cond = function()
                local ignore = {
                  "󰄽 INSERT 󰄾",
                  "󰄽 VISUAL 󰄾",
                  "󰄽 VISUAL LINE 󰄾",
                  "󰄽 VISUAL BLOCK 󰄾",
                  "󰄽 TERMINAL 󰄾",
                }
                local mode = require("noice").api.status.mode.get()
                return require("noice").api.status.mode.has() and not vim.tbl_contains(ignore, mode)
              end,
              color = utils.get_hlgroup("Comment"),
              ---@diagnostic enable: undefined-field
            },
            {
              require("lazy.status").updates,
              cond = require("lazy.status").has_updates,
              color = utils.get_hlgroup("String"),
            },
            {
              function()
                local icon = " "
                local status = require("copilot.status").data
                return icon .. (status.message or "")
              end,
              cond = function()
                local ok, clients = pcall(vim.lsp.get_clients, { name = "copilot", bufnr = 0 })
                return ok and #clients > 0
              end,
              color = function()
                if not package.loaded["copilot"] then
                  return
                end
                local status = require("copilot.status").data
                return copilot_colors[status.status] or copilot_colors[""]
              end,
            },
            {
              "diff"
            },
          },
          lualine_y = {
            {
              "progress",
            },
            {
              "location",
              color = utils.get_hlgroup("Boolean"),
            },
          },
          lualine_z = {
            {
              "datetime",
              style = "  %X",
            },
          },
        },
      }
    end,
  },
  {
    'akinsho/bufferline.nvim',
    cond = vim.g.vscode == nil,
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
    cond = vim.g.vscode == nil,
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
    cond = vim.g.vscode == nil,
    ft = 'qf',
    opts = {},
  },
  {
    'RRethy/vim-illuminate',
    cond = vim.g.vscode == nil,
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
    cond = vim.g.vscode == nil,
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
    cond = vim.g.vscode == nil,
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
        local suffix = (' 󰁂 %d 󰍻 '):format(end_lnum - lnum)
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
    cond = vim.g.vscode == nil,
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
    "nvim-neorg/neorg",
    cond = vim.g.vscode == nil,
    version = "*", -- Pin Neorg to the latest stable release
    ft = "norg", -- lazy-load on filetype
    opts = {
      load = {
        ["core.defaults"] = {},
      },
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    cond = vim.g.vscode == nil,
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
          enabled = true,
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
