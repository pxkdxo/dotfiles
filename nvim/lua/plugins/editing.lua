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
    "folke/flash.nvim",
    event = "VeryLazy",
    vscode = true,
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
      -- Simulate nvim-treesitter incremental selection
      { "<c-space>", mode = { "n", "o", "x" },
      function()
        require("flash").treesitter({
          actions = {
            ["<c-space>"] = "next",
            ["<BS>"] = "prev"
          }
        })
      end, desc = "Treesitter Incremental Selection" },
    },
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
    "https://codeberg.org/andyg/leap.nvim",
    -- cond = true,
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
        {'n', 'x', 'o'}, 's', '<Plug>(leap)'
      )
      vim.keymap.set(
        {'n'}, 'S', '<Plug>(leap-from-window)'
      )
      vim.api.nvim_set_hl(
        0, 'LeapBackdrop', { link = 'Comment' }
      )
    end,
  },
  {
    "gbprod/yanky.nvim",
    cond = true,
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
    },
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
