-- ~/.config/nvim/init.lua: Nvim initializaiton script

-- Load config package
local config = require("config")

-- Setup editor options
config.options.setup()

-- Set leader keys
vim.g.mapleader = ","
vim.g.maplocalleader = ";"

-- Set builtin fallback colorschemes
vim.g.colorschemes = { 'zaibatsu', 'shine', 'sorbet', 'habamax' }

vim.cmd.colorscheme(vim.g.colorschemes[1])

-- <Esc> to return to normal mode (even from a terminal)
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { noremap = true })
--
-- Load plugins
config.lazy.setup({
  defaults = { cond = not vim.g.vscode },
  spec = { { import = "plugins" } },
  install = { colorscheme = vim.g.colorschemes },
  checker = { enabled = false },
})

-- (If not running in VSCode) set a colorscheme and define some key mappings
if not vim.g.vscode then
  vim.g.colorschemes = {
    'cyberdream',
    'melange',
    'dayfox',
    'dawnfox',
    'carbonfox',
    'flexoki',
    'github_dark_dimmed',
    'github_light',
    'night-owl',
    'oxocarbon',
    'rose-pine',
    'rose-pine-dawn',
    'xcodedarkhc',
    'xcodelight',
    'shine',
    'sorbet',
    'habamax',
    'zaibatsu',
  }
  local colors = require("utils.colors")
  colors.setup({ colorschemes = vim.g.colorschemes })
  colors.next()

  if vim.fn.exists(':NvimTreeToggle') then
    vim.keymap.set('n', '<F1>', function () vim.cmd.NvimTreeToggle() end, { desc = "Open/Close File Explorer" })
  end

  if vim.fn.exists(':FzfLua') then
    vim.keymap.set('n', '<F2>', function() vim.cmd.FzfLua('helptags') end, { desc = "Find Helptags" })
  end

  if vim.fn.exists(':FzfLua') then
    vim.keymap.set('n', '<F3>', function() vim.cmd.FzfLua('global') end, { desc = "Find Files & Buffers & Stuff" })
  end

  if vim.fn.exists(':FzfLua') then
    vim.keymap.set('n', '<F4>', vim.cmd.GrugFar, { desc = "Search Files by Content" })
  end

  vim.keymap.set('n', '<F11>', function () vim.o.hlsearch = not vim.o.hlsearch end, { desc = "Toggle Search Highlighting" })

  vim.keymap.set('n', '<F12>', colors.next, { desc = 'Next favorite colorscheme' })

  vim.keymap.set('n', '<F24>', colors.shuffle, { desc = 'Random favorite colorschemes' })

end
