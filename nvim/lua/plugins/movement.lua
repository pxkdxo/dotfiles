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
    "folke/flash.nvim",
    event = "VeryLazy",
    cond = true,
    ---@type Flash.Config
    opts = {
      label = {
        rainbow ={
          enable = true,
        }
      }
    },
    -- stylua: ignore
    keys = {
      {
        "f",
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
        "t",
        mode = { "n", "x", "o" },
        function() require("flash").treesitter() end,
        desc = "Flash Treesitter",
      },
      {
        "T",
        mode = { "o", "x" },
        function() require("flash").treesitter_search() end,
        desc = "Treesitter Search",
      },
      {
        "<C-s>",
        mode = { "c" },
        function() require("flash").toggle() end,
        desc = "Toggle Flash Search",
      },
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
