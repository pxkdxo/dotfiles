-- lazy.lua: bootstrap lazy.nvim

local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazy_path) then
  local lazy_url = "https://github.com/folke/lazy.nvim.git"
  local argv = {"git", "clone", "--filter=blob:none", "--branch=stable", lazy_url, lazy_path}
  local system_out = vim.fn.system(argv)
  if vim.v.shell_error ~= 0 then
    local msg_chunks = {
      { "error: failed to clone lazy.nvim:\n", "ErrorMsg" },
      { system_out, "WarningMsg" },
      { "\npress any key to exit...", "Normal" },
    }
    vim.api.nvim_echo(msg_chunks, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.formatexpr = "v:lua.require('lazyvim.util').format.formatexpr()"

if vim.fn.has("nvim-0.10") == 1 then
  vim.opt.foldmethod = "expr"
  vim.opt.foldtext = ""
  vim.opt.foldexpr = "v:lua.require('lazyvim.util').ui.foldexpr()"
else
  vim.opt.foldmethod = "indent"
  vim.opt.foldtext = "v:lua.require('lazyvim.util').ui.foldtext()"
end

vim.opt.rtp:prepend(lazy_path)

return require("lazy")
