-- ~/.config/nvim/init.lua: Nvim initializaiton script

-- Disable Neovim's built-in ftplugin maps so they don't conflict with
-- nvim-treesitter-textobjects keymaps. Set early, before any ftplugin
-- runs.
vim.g.no_plugin_maps = true

-- Load config package
local config = require("config")

-- Setup editor options
config.options.setup()

-- Set leader keys
vim.g.mapleader = ","
vim.g.maplocalleader = ";"

-- <Esc> to return to normal mode (even from a terminal)
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true })

-- Set builtin fallback colorschemes
vim.g.colorschemes = {
  "shine",
  "wildcharm",
  "blue",
  "lunaperche",
  "habamax",
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
    "xcodedarkhc",
    "github_light",
    "carbonfox",
    "flexoki",
    "cyberdream",
    "dayfox",
    "dawnfox",
    "github_dark_dimmed",
    "blue",
    "oasis-dune",
    "oasis-desert",
    "flexoki-light",
    "oxocarbon",
    "xcodelight",
    "rose-pine",
    "rose-pine-dawn",
    "melange",
    "wildcharm",
    "shine",
    "lunaperche",
    "habamax",
  }
  local colors = require("utils.colors")
  colors.setup({ colorschemes = vim.g.colorschemes })
  colors.next()

  -- Function keys
  vim.keymap.set("n", "<F1>", function()
    vim.cmd.NvimTreeToggle()
  end, { desc = "Toggle File Explorer" })
  vim.keymap.set("n", "<F2>", function()
    require("fzf-lua").helptags()
  end, { desc = "Find Helptags" })
  vim.keymap.set("n", "<F3>", function()
    require("fzf-lua").global()
  end, { desc = "Find Files & Buffers & Stuff" })
  vim.keymap.set("n", "<F4>", function()
    vim.cmd.GrugFar()
  end, { desc = "Search Files by Content" })
  vim.keymap.set("n", "<F5>", function()
    require("fzf-lua").keymaps()
  end, { desc = "Find Keymaps" })
  vim.keymap.set("n", "<F6>", function()
    require("fzf-lua").commands()
  end, { desc = "Find Commands" })
  vim.keymap.set("n", "<F10>", function()
    vim.o.hlsearch = not vim.o.hlsearch
  end, { desc = "Toggle Search Highlighting" })
  vim.keymap.set("n", "<F11>", colors.prev, { desc = "Previous preferred colorscheme" })
  vim.keymap.set("n", "<F12>", colors.next, { desc = "Next preferred colorscheme" })
  vim.keymap.set("n", "<F24>", colors.shuffle, { desc = "Random preferred colorscheme" })

  -- Window navigation with <leader>w
  vim.keymap.set("n", "<leader>wh", "<C-w>h", { desc = "Go to left window" })
  vim.keymap.set("n", "<leader>wj", "<C-w>j", { desc = "Go to lower window" })
  vim.keymap.set("n", "<leader>wk", "<C-w>k", { desc = "Go to upper window" })
  vim.keymap.set("n", "<leader>wl", "<C-w>l", { desc = "Go to right window" })
  vim.keymap.set("n", "<leader>ws", "<C-w>s", { desc = "Split window below" })
  vim.keymap.set("n", "<leader>wv", "<C-w>v", { desc = "Split window right" })
  vim.keymap.set("n", "<leader>wq", "<C-w>q", { desc = "Close window" })
  vim.keymap.set("n", "<leader>wo", "<C-w>o", { desc = "Close other windows" })
  vim.keymap.set("n", "<leader>w=", "<C-w>=", { desc = "Equalize window sizes" })
  vim.keymap.set("n", "<leader>wT", "<C-w>T", { desc = "Move window to tab" })

  -- Buffer navigation with <leader>b
  vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
  vim.keymap.set("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
  vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
  vim.keymap.set("n", "<leader>bo", function()
    local current = vim.api.nvim_get_current_buf()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if buf ~= current and vim.bo[buf].buflisted then
        vim.api.nvim_buf_delete(buf, {})
      end
    end
  end, { desc = "Close other buffers" })
  vim.keymap.set("n", "<leader>bb", function()
    require("fzf-lua").buffers()
  end, { desc = "Find buffers" })

  -- Quick window resize with arrows
  vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
  vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
  vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
  vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

  -- Move lines in visual mode
  vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move lines down" })
  vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move lines up" })

  -- Better indenting (stay in visual mode)
  vim.keymap.set("v", "<", "<gv")
  vim.keymap.set("v", ">", ">gv")

  -- Quick save
  vim.keymap.set("n", "<leader><leader>", "<cmd>w<cr>", { desc = "Save file" })
end
