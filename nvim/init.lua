-- ~/.config/nvim/init.lua: Nvim initializaiton script

-- Load editor options
require("config.options")

-- Set map leader keys
vim.g.mapleader = ","
vim.g.maplocalleader = "\\"

-- Esc to return to Normal mode (even from Terminal)
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { noremap = true })

-- Load plugins
require("config.lazy").setup({
  defaults = { cond = not vim.g.vscode },
  spec = { { import = "plugins" } },
  checker = {
    enabled = false, -- do not check for plugin updates automatically
  },
  
})

-- List of colorschemesto choose from
vim.g.colorschemes = {
  'rose-pine',
  'cyberdream',
  'dayfox',
  'dawnfox',
  'oxocarbon',
  'everforest',
  'rosebones',
  'newpaper',
  'rose-pine-dawn',
  'github_light',
  'github_dark_dimmed',
  'eldritch',
  'duskfox',
  'night-owl',
  'kanagawabones',
  'shine',
  'sorbet',
  'xcodedarkhc',
  'xcodelight',
  'zaibatsu',
  'zenwritten',
  'carbonfox',
}

-- (If not running in VSCode) set a colorscheme and define some key mappings
if not vim.g.vscode then

  vim.cmd.colorscheme(vim.g.colorschemes[1])

  local rotate_colors = require('config.colorschemes')

  if vim.fn.exists(':FzfLua') then
    vim.keymap.set('n', '<F1>', function() vim.cmd.FzfLua('helptags') end, { desc = "Find Helptags" })
  end

  if vim.fn.exists(':NvimTreeToggle') then
    vim.keymap.set('n', '<F2>', function () vim.cmd.NvimTreeToggle() end, { desc = "Open/Close File Explorer" })
  end

  if vim.fn.exists(':FzfLua') then
    vim.keymap.set('n', '<F3>', function() vim.cmd.FzfLua('global') end, { desc = "Find Files & Buffers & Stuff" })
  end

  if vim.fn.exists(':FzfLua') then
    vim.keymap.set('n', '<F4>', function() vim.cmd.FzfLua('live_grep') end, { desc = "Search Files by Content" })
  end

  if vim.fn.exists(':AvanteToggle') then
    vim.keymap.set('n', '<F5>', function() vim.cmd.AvanteToggle() end, { desc = "Open/Close Avante Chat" })
  end

  vim.keymap.set('n', '<F11>', function () vim.o.hlsearch = not vim.o.hlsearch end, { desc = "Toggle Search Highlighting" })

  vim.keymap.set('n', '<F12>', function ()
    rotate_colors()
  end, { desc = 'Next favorite colorscheme' })

  vim.keymap.set('n', '<F24>', function ()
    rotate_colors({ cycle = "shuffle" })
  end, { desc = 'Random favorite colorschemes' })

end
