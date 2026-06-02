# Neovim

A Lua configuration built around lazy.nvim, organized as a set of focused,
single-concern modules rather than one monolithic init. Keyboard-driven,
LSP-complete, debugger-equipped, and wired into an externally-supervised MCP hub
for AI-assisted editing. Runs as a full editor or as the engine behind the VSCode
Neovim extension from the same files.

<!-- Screenshot: Neovim with LSP + completion, or the colorscheme picker mid-cycle -->
![Neovim](../.github/screenshots/nvim.png)

---

## Colorscheme cycling, built on a ring buffer

The part I'm most fond of. Rather than hard-coding a theme, `lua/utils/colors.lua`
implements a small **playlist over a circular doubly-linked-list deque** and applies
it to colorscheme management.

- `vim.g.colorschemes` holds an ordered list of preferred schemes, with Neovim's
  builtins at the tail as guaranteed fallbacks.
- The playlist's "play" action is `pcall(vim.cmd.colorscheme, name)` — so cycling
  **skips any scheme that isn't installed on the current machine** and falls through
  to the next, looping the ring until one applies. The same config works on every
  box without edits; missing themes are simply passed over.
- `shuffle` walks a random number of steps around the ring for a different look each
  session.

Bound to function keys:

| Key | Action |
|----|--------|
| `F11` | Previous preferred colorscheme |
| `F12` | Next preferred colorscheme |
| `Shift+F12` | Random preferred colorscheme |

The deque (`DoubleNode` / `Deque`) and `Playlist` are generic and fully
LuaCATS-annotated — colorschemes are just the first thing plugged into the `play`
callback. Cursor state is per-session (in memory), not persisted across restarts.
This pairs with the repository-level `colorschemes.py`, which fetches and links the
actual theme files; Neovim just cycles whatever is present.

---

## An options framework, not an options list

`lua/config/options.lua` isn't a flat list of `vim.opt` assignments — it's a small
**values + hooks** system. Settings are declared as data, merged over a defaults
table, and applied; `hooks.before` / `hooks.after` run functions around that pass for
options that depend on other state (e.g. `shiftwidth` derived from `expandtab` and
`softtabstop`). Callers can override any value or hook without editing the defaults.

A couple of deliberate touches in there:

- **No persistent undo in ephemeral directories.** A `BufWritePre` autocmd disables
  `undofile` for buffers under `/tmp`, `/run`, `$TMPDIR`, etc. — so editing a transient
  or sensitive file doesn't leave an undo-history artifact on disk. Set buffer-local
  (`vim.bo`) so it never leaks to unrelated buffers.
- **OSC52 clipboard awareness over SSH**, global statusline, Treesitter-based folding
  on 0.10+, and rounded window borders on 0.11+ — all gated on capability checks rather
  than assumed.

---

## LSP

LSP keymaps are attached per-buffer via a single `LspAttach` autocmd, so a buffer only
gets LSP bindings once a server actually attaches — no global maps firing on filetypes
with no server.

- Navigation (`gd`, `gD`, `gi`, `gr`, `gy`), `K` hover, signature help, and a
  `<leader>l…` group for code action, rename, format, diagnostics, and LSP info/restart.
- Inlay hints toggle is registered **only if the attached server supports it**
  (`textDocument/inlayHint`); breadcrumbs via `nvim-navic` attach only on servers that
  support document symbols.
- Servers are installed through `mason` with `mason-lspconfig` auto-enable, and default
  capabilities are wired to `nvim-cmp`.

---

## Completion

The `nvim-cmp` setup is the most involved single file. It defines:

- **Tiered sources** — AI (`avante`, `codecompanion`) and `lazydev` first, then
  `nvim_lsp`; then `ecolog`, `luasnip`, `nvim_lua`; then `buffer` / `git`. Priority is
  explicit rather than flat.
- **Custom `<Tab>` / `<CR>` logic** — Tab confirms when there's a single entry, jumps
  snippets when jumpable, falls through on leading whitespace, and otherwise triggers
  completion; CR behaves differently in insert vs. search vs. command modes.
- **Command-line completion** for `/`, `?`, and `:` with their own source sets
  (document-symbol search; cmdline + path + `ecolog` for `:`).
- Autopairs fire on completion confirm; entry icons come from `mini.icons`.

---

## Debugging, formatting, diagnostics, git

- **DAP** — `nvim-dap` with a full `<leader>d…` keymap set (breakpoints incl.
  conditional/exception, stepping, stack navigation, run-to-cursor, run-last) and custom
  breakpoint signs; `nvim-dap-ui` opens and closes automatically on session start/stop.
- **Formatting** — `conform.nvim` with per-language formatters (stylua, ruff, gofumpt,
  prettier/prettierd, shfmt, rustfmt, taplo, terraform_fmt) and format-on-save behind a
  `:FormatToggle` switch.
- **Diagnostics** — `tiny-inline-diagnostic` for inline, multiline-aware messages.
- **Git** — `gitsigns` with hunk navigation (`]h` / `[h`) and stage/reset/preview maps,
  plus `git-conflict` for merge markers.

---

## Layout

```
nvim/
  init.lua                 entry point: options, leaders, keymaps, colorscheme init
  lua/config/              lazy.nvim bootstrap and the options framework
  lua/plugins/             one file per concern (lsp, completion, dap, git, ui, ai, …)
  lua/utils/               reusable helpers (colors.lua = the playlist/deque)
  lua/core/                shared utilities
  lua/servers/             MCP server modules registered with mcphub
```

Plugins are split into single-concern files under `lua/plugins/` (LSP, DAP, Treesitter,
completion, git, formatting, diagnostics, fzf, markdown, sessions, UI, AI, …) so each
area is independently editable instead of buried in one file. The authoritative plugin
set lives in those specs and the `lazy.nvim` lockfile.

---

## AI integration

AI-assisted editing is configured around `mcphub.nvim`, `avante.nvim`, and
`codecompanion.nvim`, with a deliberate choice about how the MCP hub is run:

- **Connects to an externally-supervised hub.** `mcphub.nvim` is pointed at
  `http://localhost:37373`, the mcp-hub instance managed by launchd (macOS) or systemd
  (Linux) at the repo level — rather than spawning a second hub inside the editor. If
  that URL is unreachable, the plugin falls back to launching its own. One hub, shared
  across Claude Code, Cursor, and Neovim.
- **Tool de-confliction.** Avante's built-in file and shell tools (`read_file`,
  `create_file`, `bash`, etc.) are disabled because the MCP hub provides equivalents —
  avoiding two implementations of the same capability.
- **Provider wiring.** Credentials are read from the environment (`os.getenv`), never
  written into the config; see secret handling below.

> An example orchestrator native server under `lua/servers/` is generated tooling
> rather than hand-written, wired in only as an optional MCP server. The integration
> config is the local part.

---

## Workflow

Leaders: `,` (leader) and `;` (localleader).

Function keys drive the most-used actions — file explorer (`F1`), helptags (`F2`),
global picker (`F3`), content search via GrugFar (`F4`), keymaps (`F5`), commands
(`F6`), search-highlight toggle (`F10`), and the colorscheme keys above.

`<leader>w…` manages windows, `<leader>b…` manages buffers (including a "close other
buffers" command), `<C-Up/Down/Left/Right>` resizes, visual-mode `J`/`K` move lines and
`<`/`>` re-indent while keeping the selection, and `<leader><leader>` saves. Terminal
`<Esc>` returns to normal mode.

The whole config no-ops cleanly under VSCode: plugins default to `cond = not vim.g.vscode`,
so motion and editing behavior loads inside the VSCode Neovim extension while the UI-heavy
pieces stay out of its way. Same files, two environments.

---

## Secret handling

No credentials live in these files. API keys and tokens are read from the environment at
point of use (`os.getenv("ANTHROPIC_API_KEY")`, etc.), and the values themselves come
from an untracked `~/.env` sourced late in shell startup to limit exposure to child
processes. The repository references variables; it never defines them.
