-- ~/.config/nvim/init.lua: Nvim initializaiton script

-- Load editor options
require("config.options")

-- Set map leader keys
vim.g.mapleader = ","
vim.g.maplocalleader = ";"

-- Choose some builtin fallback colorschemes
vim.g.colorschemes = { 'zaibatsu', 'shine', 'sorbet', 'habamax' }

-- <Esc> to return to Normal mode (even from Terminal)
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { noremap = true })

vim.cmd.colorscheme(vim.g.colorschemes[1])

-- Load plugins
require("config.lazy").setup({
  defaults = { cond = not vim.g.vscode },
  spec = { { import = "plugins" } },
  install = { colorscheme = vim.g.colorschemes },
  checker = { enabled = false },
})

-- (If not running in VSCode) set a colorscheme and define some key mappings
if not vim.g.vscode then

  local colors = require("utils.colors")
  vim.g.colorschemes = {
    'cyberdream',
    'dawnfox',
    'carbonfox',
    'dayfox',
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
  colors.setup({ colorschemes = vim.g.colorschemes })
  colors.next()

  -- Add a custom keybinding to toggle the colorscheme
  vim.api.nvim_set_keymap("n", "<leader>t0", ":CyberdreamToggleMode<CR>", { noremap = true, silent = true })

  if vim.fn.exists(':FzfLua') then
    vim.keymap.set('n', '<F1>', function() vim.cmd.FzfLua('helptags') end, { desc = "Find Helptags" })
  end

  if vim.fn.exists(':FzfLua') then
    vim.keymap.set('n', '<F2>', function() vim.cmd.FzfLua('global') end, { desc = "Find Files & Buffers & Stuff" })
  end

  if vim.fn.exists(':NvimTreeToggle') then
    vim.keymap.set('n', '<F3>', function () vim.cmd.NvimTreeToggle() end, { desc = "Open/Close File Explorer" })
  end

  if vim.fn.exists(':FzfLua') then
    vim.keymap.set('n', '<F4>', function() vim.cmd.FzfLua('live_grep') end, { desc = "Search Files by Content" })
  end

  vim.keymap.set('n', '<F11>', function () vim.o.hlsearch = not vim.o.hlsearch end, { desc = "Toggle Search Highlighting" })

  vim.keymap.set('n', '<F12>', colors.next, { desc = 'Next favorite colorscheme' })

  vim.keymap.set('n', '<F24>', colors.shuffle, { desc = 'Random favorite colorschemes' })

end
