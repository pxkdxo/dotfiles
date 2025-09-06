-- This file is automatically loaded by plugins.core
local opt = vim.opt

opt.encoding = "utf-8"
opt.autoread = true
opt.autowrite = true -- Enable auto write
-- only set clipboard if not in ssh, to make sure the OSC 52
-- integration works automatically. Requires Neovim >= 0.10.0
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
opt.backspace = "indent,eol,start"
opt.belloff = "all"
opt.compatible = false
opt.complete = ".,w,b,u,t,i"
opt.completeopt = "fuzzy,menuone,noselect,preview,popup"
opt.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line
opt.cursorlineopt = "number"
opt.display = "uhex,lastline"
opt.encoding = "utf-8"
opt.expandtab = true -- Use spaces instead of tabs
opt.foldlevel = 99
opt.formatexpr = "v:lua.require'lazyvim.util'.format.formatexpr()"
opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.hidden = true
opt.history = 10000
opt.hlsearch = false
opt.ignorecase = true -- Ignore case
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
opt.number = true -- Print line number
opt.numberwidth = 2
opt.pumblend = 15 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup
-- opt.pyxversion = 3
opt.relativenumber = false -- Give us absolute line numbers
opt.ruler = true -- Enable the default ruler
opt.scrolloff = 4 -- Lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Size of an indent
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showcmd = true
opt.showmatch = true
opt.showmode = false -- Dont show mode since we have a statusline
opt.sidescroll = 1
opt.sidescrolloff = 4 -- Columns of context
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.softtabstop = 2
opt.spelllang = { "en" }
opt.splitbelow = true -- Put new windows below current
opt.splitkeep = "screen"
opt.splitright = true -- Put new windows right of current
opt.startofline = false
--opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]] -- requires 'snacks.statuscolumn'
opt.tabstop = 8 -- Number of spaces tabs count for
opt.tags = ".tags,tags,.TAGS,TAGS"
opt.termguicolors = true -- True color support
opt.timeout = true
opt.timeoutlen = vim.g.vscode and 1000 or 500 -- Lower than default (1000) to quickly trigger which-key
--opt.ttimeout = true
--opt.title = false
opt.undofile = true
opt.undolevels = 5000
opt.undoreload = -1
opt.updatecount = 48
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.whichwrap = table.concat({"<", ">", "[", "]", "b", "s"}, ",")
opt.wildignore = {".git/*", ".hg/*", ".svn/*"}
opt.wildignorecase = true
opt.wildmenu = true
opt.wildmode = {"longest:full", "full"} -- Command-line completion mode
opt.winblend = 15
opt.winborder = "rounded"
opt.winminwidth = 3 -- Minimum window width
opt.wrap = true -- Enable line wrap

if vim.fn.has("nvim-0.10") == 1 then
  opt.smoothscroll = true
end

if vim.fn.has("nvim-0.10") == 1 then
  opt.foldmethod = "expr"
  opt.foldexpr = "v:lua.require'lazyvim.util'.ui.foldexpr()"
  opt.foldtext = ""
else
  opt.foldmethod = "indent"
  opt.foldtext = "v:lua.require'lazyvim.util'.ui.foldtext()"
end

opt.directory = {
  string.format("%s/nvim/swap/", os.getenv("XDG_CACHE_HOME")),
  string.format("%s/nvim/swap/", os.getenv("XDG_DATA_HOME")),
  string.format("%s/", os.getenv("TMPDIR"))
}
opt.undodir = {
  string.format("%s/nvim/undo/", os.getenv("XDG_CACHE_HOME")),
  string.format("%s/nvim/undo/", os.getenv("XDG_DATA_HOME")),
  string.format("%s/", os.getenv("TMPDIR"))
}
opt.backupdir = {
  string.format("%s/nvim/backup/", os.getenv("XDG_CACHE_HOME")),
  string.format("%s/nvim/backup/", os.getenv("XDG_DATA_HOME")),
  string.format("%s/", os.getenv("TMPDIR"))
}
opt.guicursor = {
  "n-c-v:block",
  "r-cr-o:hor40",
  "i-ci-ve:ver65",
  "t:block-TermCursor",
  "sm:block-blinkwait250-blinkoff200-blinkon250",
  "a:blinkwait650-blinkoff250-blinkon400-Cursor/lCursor",
}

-- Fix markdown indentation settings (?)
-- vim.g.markdown_recommended_style = 0

return opt
