-- ~/.config/nvim/init.lua: Nvim initializaiton script

-- Load config package
local config = require("config")

-- Setup editor options
config.options.setup()

-- Set leader keys
vim.g.mapleader = ","
vim.g.maplocalleader = ";"

-- <Esc> to return to normal mode (even from a terminal)
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { noremap = true })

-- Set builtin fallback colorschemes
vim.g.colorschemes = {
  'shine',
  'lunaperche',
  'blue',
  'habamax',
  'wildcharm',
}

-- Load plugins
config.lazy.setup({
  defaults = { cond = not vim.g.vscode },
  spec = { { import = "plugins" } },
  install = { colorscheme = vim.g.colorschemes },
  checker = { enabled = false },
})

-- If not running in VSCode...
if not vim.g.vscode then
  vim.g.colorschemes = {
    'cyberdream',
    'carbonfox',
    'dawnfox',
    'dayfox',
    'flexoki',
    'flexoki-light',
    'github_dark_dimmed',
    'github_light',
    'habamax',
    'lunaperche',
    'melange',
    'oxocarbon',
    'rose-pine',
    'rose-pine-dawn',
    'shine',
    'wildcharm',
    'xcodedarkhc',
    'xcodelight',
    'blue',
  }
  local colors = require("utils.colors")
  colors.setup({ colorschemes = vim.g.colorschemes })
  colors.next()

  if vim.fn.exists(':NvimTreeToggle') then
    vim.keymap.set('n', '<F1>', function () vim.cmd.NvimTreeToggle() end, { desc = "Open/Close File Explorer" })
  end

  if vim.fn.exists(':FzfLua') then
    vim.keymap.set('n', '<F2>', require('fzf-lua').helptags, { desc = "Find Helptags" })
  end

  if vim.fn.exists(':FzfLua') then
    vim.keymap.set('n', '<F3>', require('fzf-lua').global, { desc = "Find Files & Buffers & Stuff" })
  end

  if vim.fn.exists(':FzfLua') then
    vim.keymap.set('n', '<F4>', vim.cmd.GrugFar, { desc = "Search Files by Content" })
  end

  if vim.fn.exists(':FzfLua') then
    vim.keymap.set('n', '<F5>', require('fzf-lua').keymaps, { desc = "Find Keymaps" })
  end

  if vim.fn.exists(':FzfLua') then
    vim.keymap.set('n', '<F6>', require('fzf-lua').commands, { desc = "Find Commands" })
  end

  vim.keymap.set('n', '<F10>', function () vim.o.hlsearch = not vim.o.hlsearch end, { desc = "Toggle Search Highlighting" })

  vim.keymap.set('n', '<F11>', colors.prev, { desc = 'Previous colorscheme preference' })
  vim.keymap.set('n', '<F12>', colors.next, { desc = 'Next colorscheme preference' })
  vim.keymap.set('n', '<F24>', colors.shuffle, { desc = 'Random preferred colorschemes' })

end
