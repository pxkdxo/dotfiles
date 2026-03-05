return {
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    opts = {
      open_mapping = '<C-`>',
      direction = 'horizontal',
      winbar = { enabled = false },
    },
    config = function (_, opts)
      local toggleterm = require('toggleterm')

      -- Setup toggleterm
      toggleterm.setup(opts)

      -- Send current line to terminal (trim_spaces=true)
      vim.keymap.set("n", "<Leader>`<Space><Enter>", function()
        toggleterm.send_lines_to_terminal("single_line", true, { args = vim.v.count })
      end)
      -- Send current line to terminal (trim_spaces=false)
      vim.keymap.set("n", "<Leader>`<Enter>", function()
        toggleterm.send_lines_to_terminal("single_line", false, { args = vim.v.count })
      end)
      -- Send selection to terminal (trim_spaces=true)
      vim.keymap.set("x", "<Leader>`<Space><Enter>", function()
        toggleterm.send_lines_to_terminal("visual_selection", true, { args = vim.v.count })
      end)
      -- Send selection to terminal  (trim_spaces=false)
      vim.keymap.set("x", "<Leader>`<Enter>", function()
        toggleterm.send_lines_to_terminal("visual_selection", false, { args = vim.v.count })
      end)
      -- Send selected lines to terminal (trim_spaces=false)
      vim.keymap.set("x", "<Leader>``<Enter>", function()
        toggleterm.send_lines_to_terminal("visual_lines", false, { args = vim.v.count })
      end)
    end,
  },
}
