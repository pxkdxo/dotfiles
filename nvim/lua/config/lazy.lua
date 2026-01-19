-- lazy.lua: bootstrap lazy.nvim

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.opt.formatexpr = "v:lua.require('lazyvim.util').format.formatexpr()"
if vim.fn.has("nvim-0.10") == 1 then
  vim.opt.foldmethod = "expr"
  vim.opt.foldtext = ""
  vim.opt.foldexpr = "v:lua.require('lazyvim.util').ui.foldexpr()"
else
  vim.opt.foldmethod = "indent"
  vim.opt.foldtext = "v:lua.require('lazyvim.util').ui.foldtext()"
end

return require("lazy")
