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
re-theme, the shell re-derives `VIVID_THEME`, the Starship palette, and the tmux statusline —
and already-open shells catch up at the next prompt. `colorschemes.py` (Python 3.12+) manages
scheme sources; inside Neovim, `F11` / `F12` / `F24` cycle them prev / next / shuffle.

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

These files follow the XDG base-directory spec. The canonical layout puts the
repository at `~/.local/etc` (which serves as `XDG_CONFIG_HOME`), the state
tree at `~/.local/var` (with cache at `~/.local/var/cache`), and makes
`~/.config`, `~/.cache`, and `~/.local/state` compat symlinks into that tree.

Clone the repo — `~/.local/etc` is the canonical spot, but anywhere works —
then run the installer, which bootstraps the whole layout on every platform
(systemd Linux, macOS, termux):

```sh
git clone --recurse-submodules https://github.com/pxkdxo/dotfiles ~/.local/etc
cd ~/.local/etc
./install-dotfiles.sh -n     # dry run — print every action without touching anything
./install-dotfiles.sh        # bootstrap + link (non-interactive)
./install-dotfiles.sh -h     # full usage
```

The installer creates the directory tree (macOS has no systemd-tmpfiles, so
this is what builds it there), places `~/.local/etc` (a symlink to the
checkout when you cloned elsewhere), migrates a pre-existing real `~/.config`
into the tree entry-by-entry, adopts `~/.cache`, links home-convention files
(shell rc, gnupg, vim, X session files) as `~/.*`, links `scripts/` into
`~/.local/bin`, and registers services (systemd user units / launchd agents).

> **Guard rails:** migrations are automatic — a lived-in home installs in one
> run — but nothing is ever deleted. Where `~/.config` and the repo both have
> an entry, the repo wins and the displaced entry is preserved in
> `~/.config.migrated/`; cache and state collisions are parked the same way.
> The only hard stop is a populated `~/.local/etc` that isn't this checkout.
> The `~/.*` links themselves do replace what's at their destination
> (including a real `~/.zshrc`), so preview with `-n` first.

Already cloned without `--recurse-submodules`? Run
`git submodule update --init --recursive`.

### Dependencies

Almost everything is probed at runtime and skipped if absent, so the hard requirements are
few; the rest enhance specific features.

- **Required:** a shell (Zsh or Bash), **git**, a standard coreutils userland.
- **Recommended (full experience):** **Neovim**, a **Nerd Font** (configs use
  *RecMonoSmCasual Nerd Font* / *Maple Mono NF*), **fzf**, **ripgrep**, **fd**, **bat**,
  **zoxide**, **Starship**, **tmux**.
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
