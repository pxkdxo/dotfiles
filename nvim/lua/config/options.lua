-- options.lua: set editor options
-- This file is automatically loaded by plugins.core

local opt = vim.opt

opt.encoding = "utf-8"
opt.autoread = true
opt.autowrite = true
opt.clipboard = vim.env.SSH_TTY and vim.fn.has("nvim-0.10") == 1 and "" or "unnamedplus" -- Sync with system clipboard
opt.backspace = "indent,eol,start"
opt.belloff = "all"
opt.compatible = false
opt.complete = ".,w,b,u,t,i"
opt.completeopt = "fuzzy,noselect,menuone,popup"
opt.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line
opt.cursorlineopt = "number"
opt.display = "uhex,lastline"
opt.encoding = "utf-8"
opt.expandtab = true -- Use spaces instead of tabs
opt.foldlevel = 99
opt.formatoptions = "jcroqlnt"
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.hidden = true
opt.history = 5000
opt.hlsearch = false -- Do not highlight search results
opt.ignorecase = true -- Ignore casei
opt.inccommand = "nosplit" -- preview incremental substitute
opt.incsearch = true
opt.jumpoptions = "view"
opt.keywordprg = ":Man"
opt.laststatus = 3 -- global statusline
opt.linebreak = true -- Wrap lines at convenient points
opt.list = true -- Show some invisible characters (tabs...
opt.modeline = true
opt.mouse = "a" -- Enable mouse mode
opt.mousefocus = true
opt.nrformats = "bin,hex,unsigned"
opt.number = true -- Show line numbers
opt.numberwidth = 3 -- Min width of number column
opt.pumblend = 15 -- Popup blend
opt.pumheight = 25 -- Maximum number of entries in a popup
opt.relativenumber = false -- Give us absolute line numbers
opt.ruler = true -- Enable the default ruler
opt.scrolloff = 3 -- Lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Size of an indent
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showcmd = true
opt.showmatch = true
opt.showmode = false -- Dont show mode since we have a statusline
opt.sidescroll = 1
opt.sidescrolloff = 3 -- Columns of context
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.softtabstop = 2
opt.spelllang = { "en" }
opt.splitbelow = true -- Put new windows below current
opt.splitkeep = "screen"
opt.splitright = true -- Put new windows right of current
opt.startofline = false
opt.tabstop = 8 -- Number of spaces per tab
opt.tags = table.concat({".tags", ".TAGS", "tags", "TAGS"}, ",")
opt.termguicolors = true -- True color support
opt.timeout = true
opt.timeoutlen = vim.g.vscode and 1000 or 550 -- Lower than default (1000) to quickly trigger which-key
--opt.ttimeout = true
opt.undofile = opt.swapfile and true or false
opt.undolevels = 2500
opt.undoreload = -1
-- opt.updatecount = 100 -- Save swap file and trigger CursorHold
-- opt.updatetime = 2500 -- Uncomment to use a non-default interval
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.whichwrap = table.concat({"<", ">", "[", "]", "b", "s"}, ",")
opt.wildignore = {".git/*", ".hg/*", ".svn/*"}
opt.wildignorecase = true
opt.wildmenu = true
opt.wildmode = {"list:longest:full", "full"} -- Command-line completion mode
opt.winblend = 15
opt.winborder = "rounded"
opt.winminwidth = 5 -- Minimum window width

if vim.fn.has("nvim-0.10") ~= 0 then
  opt.smoothscroll = true
end

opt.directory:prepend(string.format("%s/swap/", vim.fn.stdpath("state")))
opt.directory:append(string.format("%s/nvim/swap/", vim.fn.stdpath("run")))

opt.undodir:prepend(string.format("%s/undo/", vim.fn.stdpath("state")))
opt.undodir:append(string.format("%s/nvim/undo/", vim.fn.stdpath("run")))

opt.backupdir:prepend(string.format("%s/backup/", vim.fn.stdpath("state")))
opt.backupdir:append(string.format("%s/nvim/backup/", vim.fn.stdpath("run")))

vim.cmd.autocmd({
  args = {
    "BufWritePre", table.concat({
      "/run/*",
      "/tmp/*",
      "/var/run/*",
      "/var/tmp/*",
      (vim.fn.stdpath("run") or "/var/run") .. "/*",
      (vim.env.TMPDIR or "/var/tmp") .. "/*",
    }, ","),
    "setlocal", "noundofile",
  },
})

return { setup = function (_) return opt end }
