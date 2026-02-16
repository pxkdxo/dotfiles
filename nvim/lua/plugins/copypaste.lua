return {
  {
    "gbprod/yanky.nvim",
    opts = {
      system_clipboard = {
        sync_with_ring = true,
        clipboard_register = "+",
      },
      highlight = {
        on_put = true,
        on_yank = true,
        timer = 200,
      },
    },
    config = function (_, opts)
      local yanky = require("yanky")
      yanky.setup(opts)
      vim.keymap.set({"n","x"}, "p", "<Plug>(YankyPutAfter)")
      vim.keymap.set({"n","x"}, "P", "<Plug>(YankyPutBefore)")
      vim.keymap.set({"n","x"}, "gp", "<Plug>(YankyGPutAfter)")
      vim.keymap.set({"n","x"}, "gP", "<Plug>(YankyGPutBefore)")
      vim.keymap.set({"n","x"}, "p", "<Plug>(YankyPutAfter)")
      vim.keymap.set("n", "<C-p>", "<Plug>(YankyPreviousEntry)")
      vim.keymap.set("n", "<C-n>", "<Plug>(YankyNextEntry)")
      return yanky
    end,
  }
}
