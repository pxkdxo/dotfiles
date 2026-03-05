return {
  {
    "gbprod/yanky.nvim",
    dependencies = {
      { "kkharji/sqlite.lua" },
      { "folke/snacks.nvim" },
    },
    opts = {
      preserve_cursor_position = {
        enabled = true,
      },
      ring = {
        history_length = 250,
        storage = "sqlite",
        update_register_on_cycle = true,
      },
      system_clipboard = {
        clipboard_register = "+",
        -- Uncomment below to keep the yank ring separate from the system clipboard
        -- sync_with_ring = false,
      },
    },
    keys = {
      {
        "<leader>p",
        function()
          Snacks.picker.yanky()
        end,
        mode = { "n", "x" },
        desc = "Open Yank History",
      },
      { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
      { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after cursor" },
      { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before cursor" },
      { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after cursor and leave cursor after" },
      { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before cursor and leave cursor after" },
      { "<C-p>", "<Plug>(YankyPreviousEntry)", desc = "Select previous entry through yank history" },
      { "<C-n>", "<Plug>(YankyNextEntry)", desc = "Select next entry through yank history" },
      { "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put after applying a filter" },
      { "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put before applying a filter" },
    },
    config = function (_, opts)
      local yanky = require("yanky")
      yanky.setup(opts)
      vim.keymap.set({"n","x"}, "p", "<Plug>(YankyPutAfter)")
      vim.keymap.set({"n","x"}, "P", "<Plug>(YankyPutBefore)")
      vim.keymap.set({"n","x"}, "gp", "<Plug>(YankyGPutAfter)")
      vim.keymap.set({"n","x"}, "gP", "<Plug>(YankyGPutBefore)")
      vim.keymap.set("n", "<C-p>", "<Plug>(YankyPreviousEntry)")
      vim.keymap.set("n", "<C-n>", "<Plug>(YankyNextEntry)")
      return yanky
    end,
  }
}
