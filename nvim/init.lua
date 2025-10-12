-- ~/.config/nvim/init.lua: Nvim initializaiton script

-- Load editor options
require("config.options")

-- Set map leader keys
vim.g.mapleader = ","
vim.g.maplocalleader = ";"
vim.g.colorschemes_fav = {
  'cyberdream',
  'dawnfox',
  'oxocarbon',
  'dayfox',
  'rose-pine',
  'carbonfox',
  'github_dark',
  'github_dark_dimmed',
  'github_dark_light',
  'sorbet',
}

-- Load plugins
require("config.lazy").setup({
  spec = { { import = "plugins" } },
  checker = { enabled = true },
  ui = {
    size = { width = 0.8, height = 0.85 },
    wrap = true,
    border = "none",
    backdrop = 20,
    pills = true,
  },
})

if not vim.g.vscode then
  vim.cmd.colorscheme("rose-pine")

  vim.keymap.set('n', '<F12>', function ()
    local current = vim.g.colors_name
    local choices = {}
    for _, colors in ipairs(vim.g.colorschemes_fav) do
      if colors ~= current then table.insert(choices, { colors }) end
    end
    vim.cmd.colorscheme(choices[math.random(#choices)])
  end, { desc = "Change the colorscheme" })

  vim.keymap.set('n', '<F11>', function () vim.o.hlsearch = not vim.o.hlsearch end, { desc = "Toggle search highlighting" })

  vim.keymap.set('n', '<F5>', function() vim.cmd.AvanteToggle() end, { desc = "Open/close Avante chat" })

  vim.keymap.set('n', '<F4>', function() vim.cmd.FzfLua() end, { desc = "Open FzfLua" })

  vim.keymap.set('n', '<F3>', function () vim.cmd.NvimTreeToggle() end, { desc = "Open/close file explorer" })

  vim.keymap.set('n', '<F2>', FzfLua.global, { desc = "Find bufs & stuff (FzfLua) " })

  vim.keymap.set('n', '<F1>', FzfLua.helptags, { desc = "Find helptags (FzfLua)" })
end
