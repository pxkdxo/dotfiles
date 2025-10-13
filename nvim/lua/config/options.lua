-- This file is automatically loaded by plugins.core

local opt = vim.opt

local function default(x, d)
  if x ~= nil then 
    return x
  else
    return d
  end
end

opt.encoding = "utf-8"
opt.autoread = true
opt.autowrite = true
-- Only set clipboard if not in ssh to make sure the OSC 52 integration works
-- * requires Neovim >= 0.10.0
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
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
opt.formatexpr = "v:lua.require'lazyvim.util'.format.formatexpr()"
opt.formatoptions = "jcroqlnt"
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.hidden = true
opt.history = 5000
opt.hlsearch = true -- Highlight search results
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
opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]] -- requires 'snacks.statuscolumn'
opt.tabstop = 8 -- Number of spaces tabs count for
opt.tags = ".tags,tags,.TAGS,TAGS"
opt.termguicolors = true -- True color support
opt.timeout = true
opt.timeoutlen = vim.g.vscode and 1000 or 600 -- Lower than default (1000) to quickly trigger which-key
--opt.ttimeout = true
--opt.title = false
opt.undofile = opt.swapfile and true or false
opt.undolevels = 2000
opt.undoreload = -1
opt.updatecount = 100
opt.updatetime = 2500 -- Save swap file and trigger CursorHold
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.whichwrap = table.concat({"<", ">", "[", "]", "b", "s"}, ",")
opt.wildignore = {".git/*", ".hg/*", ".svn/*"}
opt.wildignorecase = true
opt.wildmenu = true
opt.wildmode = {"list:longest:full", "full"} -- Command-line completion mode
opt.winblend = 15
opt.winborder = "rounded"
opt.winminwidth = 8 -- Minimum window width

-- -- Enable line wrap
-- opt.wrap = true

if vim.fn.has("nvim-0.10") == 1 then
  opt.smoothscroll = true
  opt.foldmethod = "expr"
  opt.foldexpr = "v:lua.require'lazyvim.util'.ui.foldexpr()"
  opt.foldtext = ""
else
  opt.foldmethod = "indent"
  opt.foldtext = "v:lua.require'lazyvim.util'.ui.foldtext()"
end

opt.directory:prepend({
  string.format("%s/nvim/swap", default(
    os.getenv("XDG_STATE_HOME"), string.format(
      "%s/%s", os.getenv("HOME"), ".local/state"
    )
  ))
})
opt.directory:append({
  string.format("%s/nvim/swap", default(
    os.getenv("XDG_RUNTIME_DIR"), default(os.getenv("TMPDIR"), '/tmp')
  ))
})
opt.undodir:prepend({
  string.format("%s/nvim/undo", default(
    os.getenv("XDG_STATE_HOME"), string.format(
      "%s/%s", os.getenv("HOME"), ".local/state"
    )
  ))
})
opt.undodir:append({
  string.format("%s/nvim/undo", default(
    os.getenv("XDG_RUNTIME_DIR"), default(os.getenv("TMPDIR"), '/tmp')
  ))
})
opt.backupdir:prepend({
  string.format("%s/nvim/backup", default(
    os.getenv("XDG_STATE_HOME"), string.format(
      "%s/%s", os.getenv("HOME"), ".local/state"
    )
  ))
})
opt.backupdir:append({
  string.format("%s/nvim/backup", default(
    os.getenv("XDG_RUNTIME_DIR"), default(os.getenv("TMPDIR"), '/tmp')
  ))
})

vim.cmd.autocmd({
  args = {
    "BufWritePre",
    table.concat(
      {
        "/run/*",
        "/tmp/*",
        "/var/run/*",
        "/var/tmp/*",
        string.format("%s/*", default(os.getenv("XDG_RUNTIME_DIR"), "/var/run")),
        string.format("%s/*", default(os.getenv("TMPDIR"), "/tmp")),
      },
      ","
    ),
    "setlocal",
    "noundofile",
  },
})

return opt
