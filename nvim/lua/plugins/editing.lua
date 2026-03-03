return {
  {
    "kylechui/nvim-surround",
    cond = true,
    version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },
  {
    'Wansmer/treesj',
    cond = true,
    dependencies = {
      -- if you install parsers with `nvim-treesitter`
      'nvim-treesitter/nvim-treesitter',
    },
    opts = {
      vuse_default_keymaps = false,
    },
    config = function (_, opts)
      local treesj = require('treesj')
      treesj.setup(opts)
      vim.keymap.set('n', '<Space>t', treesj.toggle) -- default preset
      vim.keymap.set('n', '<Space>T', function() -- default preset with 'recursive = true'
        treesj.toggle({ split = { recursive = true } })
      end)
      vim.keymap.set('n', '<Space>s', treesj.split) -- default preset
      vim.keymap.set('n', '<Space>j', treesj.join) -- default preset
    end
  },
  {
    "MagicDuck/grug-far.nvim",
    cond = vim.g.vscode == nil,
    opts = { headerMaxWidth = 80 },
    cmd = { "GrugFar", "GrugFarWithin" },
    keys = {
      {
        "<leader>sr",
        function()
          local grug = require("grug-far")
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          grug.open({
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= "" and "*." .. ext or nil,
            },
          })
        end,
        mode = { "n", "x" },
        desc = "Search and Replace",
      },
    },
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    cond = true,
    vscode = true,
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      {
        "C-g",
        mode = { "n", "x", "o" },
        function() require("flash").jump() end,
        desc = "Flash",
      },
      {
        "F",
        mode = "o",
        function() require("flash").remote() end,
        desc = "Remote Flash",
      },
      {
        "C-s",
        mode = { "o", "x" },
        function() require("flash").treesitter_search() end,
        desc = "Treesitter Search",
      },
      {
        "<C-f>",
        mode = { "c" },
        function() require("flash").toggle() end,
        desc = "Toggle Flash Search",
      },
      -- Simulate nvim-treesitter incremental selection
      {
        "<C-f>", mode = { "n", "o", "x" }, function()
          require("flash").treesitter({
            actions = {
              ["<C-f>"] = "next",
              ["<C-b>"] = "prev"
            }
          })
        end,
        desc = "Treesitter Incremental Selection"
      },
    },
  },
  {
    "https://codeberg.org/andyg/leap.nvim",
    cond = false,
    version = false,
    opts = {
      preview_filter = function (ch0, ch1, ch2)
        return not (
          ch1:match('%s') or
          ch0:match('%a') and ch1:match('%a') and ch2:match('%a')
        )
      end,
    },
    config = function (_, opts)
      require("leap").setup(opts)
      require('leap.user').set_repeat_keys(
   '<enter>', '<backspace>'
      )
      vim.keymap.set(
        {'n', 'x', 'o'}, 'f', '<Plug>(leap)'
      )
      vim.keymap.set(
        {'n', 'x', 'o'}, 'F', '<Plug>(leap-from-window)'
      )
      vim.api.nvim_set_hl(
        0, 'LeapBackdrop', { link = 'Comment' }
      )
    end,
  },
  {
    'windwp/nvim-autopairs',
    cond = true,
    event = "InsertEnter",
    opts = {
      fast_wrap = {
        chars = { '{', '[', '(', '"', "'" },
        disable_filetype = { "TelescopePrompt" , "guihua", "guihua_rust", "clap_input" },
        pattern = [=[[%'%"%>%]%)%}%,]]=],
        end_key = '$',
        before_key = 'h',
        after_key = 'l',
        cursor_pos_before = true,
        keys = 'qwertyuiopzxcvbnmasdfghjkl',
        manual_position = true,
        highlight = 'Search',
        highlight_grey='Comment',
      },
    },
  },
  {
    'stevearc/conform.nvim',
    cond = vim.g.vscode == nil,
    opts = {},
  },
}
