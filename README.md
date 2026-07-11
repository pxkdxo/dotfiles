# dotfiles

![macOS](https://img.shields.io/badge/macOS-000000?logo=apple&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black)
![Neovim](https://img.shields.io/badge/Neovim-57A143?logo=neovim&logoColor=white)
![Shell](https://img.shields.io/badge/POSIX_sh-4EAA25?logo=gnubash&logoColor=white)

A keyboard-driven development environment for macOS and Linux, configured as a system
rather than a collection of configs. Neovim · Zsh · Tmux · Starship · fzf — with live
theming, AI tools, and graceful fallbacks throughout.

---

## Highlights

**Light/dark that follows the whole machine.** Theme definitions live in one place and
propagate to every tool — Neovim, Alacritty, Ghostty, Kitty, Foot, bat, and `LS_COLORS` via
vivid. Flip macOS dark mode or GNOME's `color-scheme` and the change propagates live: terminals
re-theme, the shell re-derives `VIVID_THEME`, the Starship palette, the tmux statusline, and
fzf's colors — and already-open shells catch up at the next prompt. `colorschemes.py`
(Python 3.12+) manages scheme sources; inside Neovim, `F11` / `F12` / `F24` cycle them
prev / next / shuffle.

**AI-assisted editing stack.** [Avante.nvim](https://github.com/yetone/avante.nvim) drives
agentic editing via `cursor-agent` (ACP); [MCPHub.nvim](https://github.com/ravitemer/mcphub.nvim)
routes MCP tools into it — connecting to an externally-managed hub rather than spawning a
duplicate, and replacing Avante's built-in file/bash tools with the hub's equivalents.
Copilot handles inline completions.

**Neovim works inside VSCode.** The full config loads inside vscode-neovim, with UI plugins
gated off and motion/editing plugins active. No separate VSCode config.

**Built to degrade gracefully.** Shell drop-ins detect what's present (`command -v`) and
fall through ordered backends rather than assuming a tool exists — clipboard across several
providers, `command-not-found` resolution probing the usual system paths, XDG-aware language
setup. A partial install means fewer features, not breakage.

**Portable.** XDG base-directory compliant throughout; macOS uses launchd agents, Linux uses
systemd user units. Shell startup is POSIX-portable across both.

---

## What's inside

| Tool | Config |
|---|---|
| **Neovim** | Lua · lazy.nvim · full LSP (mason) · blink.cmp · Treesitter · Avante + MCPHub + Copilot · which-key |
| **Zsh** | Oh-My-Zsh (personal fork) · fzf bindings · zoxide · fast-syntax-highlighting · autosuggestions |
| **Tmux** | Vi keys · true-color · system clipboard · auto light/dark statusline · socket-activated user service |
| **Starship** | Two-line prompt · git status · language versions · AWS context |
| **Terminals** | Alacritty · Ghostty · Kitty · Foot — coordinated, auto light/dark |
| **Bat / Ripgrep / Vivid** | Pager · search · `LS_COLORS` theming |
| **Yazi / Ranger** | Terminal file managers |
| **Git** | Aliases · color config |

> The Neovim config has its own [README](nvim/) covering the colorscheme engine, the AI
> stack, and the module layout.

---

## Installation

The layout is XDG throughout, arranged as a prefix-style tree:

```
~/.local/etc                          this repository — serves as XDG_CONFIG_HOME
~/.local/var                          XDG_STATE_HOME · cache at var/cache · tmp at var/tmp
~/.config  ~/.cache  ~/.local/state   compat symlinks into the tree
```

Clone — `~/.local/etc` is the canonical spot, but anywhere works — and run
the installer, which bootstraps the whole layout on every platform (systemd
Linux, macOS, termux):

```sh
git clone --recurse-submodules https://github.com/pxkdxo/dotfiles ~/.local/etc
cd ~/.local/etc
./install-dotfiles.sh -n     # dry run — print every action without touching anything
./install-dotfiles.sh        # bootstrap + link (non-interactive)
./install-dotfiles.sh -h     # full usage
```

One run takes a lived-in home to the full layout. The installer creates the
tree (macOS has no systemd-tmpfiles; this is what builds it there), places
`~/.local/etc` (a symlink when you cloned elsewhere), migrates a real
`~/.config` into the tree entry-by-entry, folds `~/.cache` and
`~/.local/state` into `~/.local/var`, links home-convention files (shell rc,
gnupg, vim, X session files) as `~/.*`, links `scripts/` into `~/.local/bin`,
and registers services (systemd user units / launchd agents).

> **Guard rails:** nothing in this system deletes your data — not the
> installer, and not login-time management (the tmpfiles configs are
> create-only by design). On a migration collision the repo wins and the
> displaced entry is parked in a `*.migrated/` directory. The one hard stop
> is a populated `~/.local/etc` that isn't this checkout. The `~/.*` links do
> replace what's at their destination (including a real `~/.zshrc`), so
> preview with `-n` first.

Already cloned without `--recurse-submodules`? Run
`git submodule update --init --recursive`.

### Dependencies

Almost everything is probed at runtime and skipped if absent, so the hard requirements are
few; the rest enhance specific features.

- **Required:** a shell (Zsh or Bash), **git**, a standard coreutils userland.
- **Recommended (full experience):** **Neovim**, a **Nerd Font** (configs use
  *SpaceMono Nerd Font*), **fzf**, **ripgrep**, **fd**, **bat**, **zoxide**, **vivid**,
  **Starship**, **tmux**.
- **Neovim AI stack:** **node** / **npm** (MCPHub builds `mcp-hub`), **make** + a C
  compiler (Avante), and `cursor-agent` for the ACP provider.
- **Optional, per feature:** **eza** / **lsd** (dir previews) · **wl-clipboard** / **xsel** /
  **xclip** (clipboard) · **pass** + **gnupg** (password store) · **podman** (Docker
  substitute) · **go** / **rust** / **java** / **cabal** (language envs) · **yarn** (markdown
  preview) · **gh**, **kubectl**, **htop**.

---

## Usage

`F11` / `F12` / `F24` — cycle colorschemes prev / next / shuffle. Everything else lives under
`,` (leader); press it and wait for the which-key popup. Function keys cover the common
actions — file explorer (`F1`), fzf pickers and search/replace (`F2`–`F6`), search-highlight
toggle (`F10`).

In Zsh, `Ctrl+Space` (`^@`) triggers interactive directory completion (`cd` with fzf);
`Alt+z` opens zoxide's interactive jump picker.

---

## Secret handling

No credentials live in this repository. API keys and tokens are read from the environment at
point of use; the values themselves come from an untracked `~/.env`, sourced late in shell
startup to limit exposure to child processes. The repo references variables — it never
defines them.

---

## Author

[Patrick DeYoreo](https://github.com/pxkdxo) — platform engineer (DevOps,
Cloud)
