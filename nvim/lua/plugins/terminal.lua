return {
  {
    'akinsho/toggleterm.nvim',
    cond = vim.g.vscode == nil,
    version = "*",
    opts = {
      open_mapping = '<C-`>',
      direction = 'horizontal',
      winbar = { enabled = false },
    },
    config = function (_, opts)
      local toggleterm = require('toggleterm')
      local trim_spaces = true

      -- Setup toggleterm
      toggleterm.setup(opts)

      -- Send current line to terminal
      vim.keymap.set("n", "<Leader>`X", function()
        toggleterm.send_lines_to_terminal("single_line", trim_spaces, { args = vim.v.count })
      end)

      -- Send visual selection to terminal
      vim.keymap.set("x", "<Leader>`x", function()
        toggleterm.send_lines_to_terminal("visual_selection", trim_spaces, { args = vim.v.count })
      end)
    end,
  },
}
