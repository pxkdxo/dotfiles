-- ~/.config/nvim/init.lua: Nvim initializaiton script

-- Load editor options
require("config.options")

-- Set map leader keys
vim.g.mapleader = ","
vim.g.maplocalleader = ";"

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

-- Keep a list of some good colorschemes
vim.g.colorschemes = {
  'oxocarbon',
  'rose-pine',
  'cyberdream',
  'carbonfox',
  'dawnfox',
  'dayfox',
  'github_light',
  'github_dark_dimmed',
  'xcodelight',
  'xcodedarkhc',
  'sorbet',
}

-- Set a colorscheme and define some key mappings if not running in VSCode
if not vim.g.vscode then

  vim.cmd.colorscheme(vim.g.colorschemes[1])

  vim.keymap.set('n', '<F12>', function ()
    local choices = {}
    if vim.g.colorschemes ~= nil then
      for _, colors in ipairs(vim.g.colorschemes or {vim.g.colors_name}) do
        if colors ~= vim.g.colors_name then
          table.insert(choices, { colors })
        end
      end
    end
    if #choices > 0 then
      vim.cmd.colorscheme(choices[math.random(#choices)])
    end
  end, { desc = "Change the colorscheme" })

  vim.keymap.set('n', '<F11>', function () vim.o.hlsearch = not vim.o.hlsearch end, { desc = "Toggle search highlighting" })

  if vim.fn.exists(':AvanteToggle') then
    vim.keymap.set('n', '<F5>', function() vim.cmd.AvanteToggle() end, { desc = "Open/close Avante chat" })
  end

  if vim.fn.exists(':FzfLua') then
    vim.keymap.set('n', '<F4>', function() vim.cmd.FzfLua() end, { desc = "Open FzfLua" })
  end

  if vim.fn.exists(':NvimTreeToggle') then
    vim.keymap.set('n', '<F3>', function () vim.cmd.NvimTreeToggle() end, { desc = "Open/close file explorer" })
  end

  if vim.fn.exists(':FzfLua') then
    vim.keymap.set('n', '<F2>', function() vim.cmd.FzfLua('global') end, { desc = "Find bufs & stuff (FzfLua) " })
  end

  if vim.fn.exists(':FzfLua') then
    vim.keymap.set('n', '<F1>', function() vim.cmd.FzfLua('helptags') end, { desc = "Find helptags (FzfLua)" })
  end
end
