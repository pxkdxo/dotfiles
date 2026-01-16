-- options.lua: set editor options
-- This file is automatically loaded by plugins.core

vim.opt.encoding = "utf-8"
vim.opt.autoread = true
vim.opt.autowrite = true
vim.opt.backspace = "indent,eol,start"
vim.opt.belloff = "all"

if vim.fn.has("nvim-0.10") == 1 and vim.env.SSH_TTY ~= nil then
  vim.opt.clipboard = "" -- Copy/paste over SSH
else
  vim.opt.clipboard = "unnamedplus" -- Sync with system clipboard
end

vim.opt.cmdheight = 0
vim.opt.complete = ".,w,b,u,t,i"
vim.opt.completeopt = "fuzzy,noselect,menuone,popup"
vim.opt.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions
vim.opt.confirm = true -- Confirm to save changes before exiting modified buffer
vim.opt.cursorline = true -- Enable highlighting of the current line
vim.opt.cursorlineopt = "line,number"
vim.opt.display = "uhex,lastline"
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.foldlevel = 99
vim.opt.formatoptions = "jcroqlnt"
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.grepprg = "rg --vimgrep"
vim.opt.hidden = true
vim.opt.history = 10000
vim.opt.hlsearch = false -- Do not highlight search results
vim.opt.ignorecase = true -- Ignore casei
vim.opt.inccommand = "nosplit" -- preview incremental substitute
vim.opt.incsearch = true
vim.opt.jumpoptions = "view"
vim.opt.keywordprg = ":Man"
vim.opt.laststatus = 3 -- global statusline
vim.opt.linebreak = true -- Wrap lines at convenient points
vim.opt.list = true -- Show some invisible characters (tabs...
vim.opt.modeline = true
vim.opt.mouse = "a" -- Enable mouse mode
vim.opt.mousefocus = true
vim.opt.nrformats = "bin,hex,unsigned"
vim.opt.number = true -- Show line numbers
vim.opt.numberwidth = 3 -- Min width of number column
vim.opt.pumblend = 15 -- Popup blend
vim.opt.pumheight = 30 -- Maximum number of entries in a popup
vim.opt.relativenumber = false -- Give us absolute line numbers
vim.opt.ruler = true -- Enable the default ruler
vim.opt.scrolloff = 3 -- Lines of context
vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
vim.opt.shiftround = true -- Round indent
vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })
vim.opt.showcmd = true
vim.opt.showmatch = true
vim.opt.showmode = false -- Dont show mode since we have a statusline
vim.opt.sidescroll = 1
vim.opt.sidescrolloff = 3 -- Columns of context
vim.opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
vim.opt.smartcase = true -- Don't ignore case with capitals
vim.opt.smartindent = true -- Insert indents automatically
if vim.fn.has("nvim-0.10") == 1 then
  vim.opt.smoothscroll = true
end
vim.opt.softtabstop = 2
vim.opt.shiftwidth = vim.o.expandtab and vim.o.softtabstop or 0
vim.opt.spelllang = { "en" }
vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitkeep = "screen"
vim.opt.splitright = true -- Put new windows right of current
vim.opt.startofline = false
vim.opt.tabstop = 8 -- Number of spaces per tab
vim.opt.tags = table.concat({".tags", ".TAGS", "tags", "TAGS"}, ",")
vim.opt.termguicolors = true -- True color support
vim.opt.timeout = true
vim.opt.timeoutlen = vim.g.vscode and 1000 or 500 -- Lower than default (1000) to quickly trigger which-key
--vim.opt.ttimeout = true
vim.opt.undofile = vim.o.swapfile and true or false
vim.opt.undolevels = 2500
vim.opt.undoreload = -1
vim.opt.updatecount = 25 -- Save swap file and trigger CursorHold
vim.opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
vim.opt.whichwrap = table.concat({"<", ">", "[", "]", "b", "s"}, ",")
vim.opt.wildignore = {".git/*", ".hg/*", ".svn/*"}
vim.opt.wildignorecase = true
vim.opt.wildmenu = true
vim.opt.wildmode = {"longest:noselect", "full"} -- Command-line completion mode
vim.opt.winblend = 20
vim.opt.winborder = "rounded"
vim.opt.winminwidth = 10 -- Minimum window width

vim.opt.directory:prepend(string.format("%s/swap/", vim.fn.stdpath("state")))
vim.opt.directory:append(string.format("%s/nvim/swap/", vim.fn.stdpath("run")))

vim.opt.undodir:prepend(string.format("%s/undo/", vim.fn.stdpath("state")))
vim.opt.undodir:append(string.format("%s/nvim/undo/", vim.fn.stdpath("run")))

vim.opt.backupdir:prepend(string.format("%s/backup/", vim.fn.stdpath("state")))
vim.opt.backupdir:append(string.format("%s/nvim/backup/", vim.fn.stdpath("run")))

vim.cmd.autocmd({
  args = {
    "BufWritePre",
    table.concat({
      "/run/*",
      "/var/run/*",
      string.format("%s/*", vim.fn.stdpath("run") or "/var/run"),
      "/tmp/*",
      "/var/tmp/*",
      string.format("%s/*", vim.env.TMPDIR or "/var/tmp"),
    }, ","),
    "setlocal",
    "noundofile",
  },
})

return vim.opt
