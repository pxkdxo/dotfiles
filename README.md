# dotfiles

![macOS](https://img.shields.io/badge/macOS-000000?logo=apple&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black)
![Neovim](https://img.shields.io/badge/Neovim-57A143?logo=neovim&logoColor=white)
![Shell](https://img.shields.io/badge/POSIX_sh-4EAA25?logo=gnubash&logoColor=white)

A keyboard-driven development environment for macOS and Linux — managed like
infrastructure. Neovim · Zsh · Tmux · Starship · fzf, configured to work together.

<!-- screenshot: nvim with LSP, lualine, bufferline -->
![Neovim](.github/screenshots/nvim.png)

---

## Highlights

**Coordinated colorscheme system.** Theme definitions live in one place and propagate to
every tool — Neovim, Alacritty, Kitty, Foot, bat, and `LS_COLORS` via vivid. A small
`colorschemes.py` (typed Python 3.12+) fetches themes from Git repos or local dirs and links
them into a per-app layout; a thin symlink layer lets each terminal switch the active theme
without editing its config. Inside Neovim, a custom `Deque` / `Playlist` engine rotates
through schemes at runtime (`F11` / `F12` / `F24`), skipping any not installed on the box.

<!-- screenshot: colorscheme cycling (multiple frames or GIF) -->
![Colorscheme cycling](.github/screenshots/colorschemes.gif)

**AI-first editing stack.** [Avante.nvim](https://github.com/yetone/avante.nvim) drives
agentic editing via `cursor-agent` (ACP); [MCPHub.nvim](https://github.com/ravitemer/mcphub.nvim)
routes MCP tools into it — connecting to an externally-supervised hub (launchd on macOS,
systemd on Linux) rather than spawning a duplicate, and replacing Avante's built-in
file/bash tools with the hub's equivalents. Copilot handles inline completions.

**Neovim works inside VSCode.** The entire config loads inside vscode-neovim — motion and
editing plugins force-enabled, everything else gated behind `cond = vim.g.vscode == nil`.
No separate VSCode config.

**Built to degrade gracefully.** Shell drop-ins detect what's present (`command -v`) and
fall through ordered backends rather than assuming a tool exists — clipboard across a dozen
providers, `command-not-found` across seven distros, XDG-aware language setup. A partial
install means fewer features, not breakage.

**Cross-platform by construction.** XDG base-directory compliant throughout. macOS uses
launchd agents; Linux uses systemd user units. Shell startup
(`zshenv` → `zprofile` → `zshrc`, plus `profile.d/` and `environment.d/`) is POSIX-portable.

---

## What's inside

| Tool | Config |
|---|---|
| **Neovim** | Lua · lazy.nvim · full LSP (mason) · nvim-cmp · Treesitter · Avante + MCPHub + Copilot · which-key |
| **Zsh** | Oh-My-Zsh (personal fork) · fzf bindings · zoxide · fast-syntax-highlighting · autosuggestions |
| **Tmux** | Vi keys · true-color · system clipboard · powerline status · socket-activated user service |
| **Starship** | Two-line prompt · git status · language versions · AWS context |
| **Terminals** | Alacritty (primary) · Kitty · Foot — coordinated colorschemes |
| **Bat / Ripgrep / Vivid** | Pager · search · `LS_COLORS` theming |
| **Yazi / Ranger** | Terminal file managers |
| **Git** | Aliases · color config |

<!-- screenshot: tmux panes + starship prompt -->
![Terminal + Tmux](.github/screenshots/tmux.png)

> The Neovim config has its own [README](nvim/) covering the colorscheme engine, the AI
> stack, and the module layout.

---

## Installation

These files follow the XDG base-directory spec and are designed to live at `~/.config`.

Clone directly into your config directory:

```sh
git clone --recurse-submodules https://github.com/pxkdxo/dotfiles ~/.config
```

> **Note:** this replaces your existing `~/.config`. Back it up first, or clone elsewhere
> and merge selectively. Already cloned without `--recurse-submodules`? Run
> `git submodule update --init --recursive`.

Or use the install script to symlink individual files as `~/.*`:

```sh
git clone --recurse-submodules https://github.com/pxkdxo/dotfiles
cd dotfiles
./install-dotfiles.sh        # interactive — prompts before replacing
./install-dotfiles.sh -f     # force-replace
./install-dotfiles.sh -n     # dry run
./install-dotfiles.sh -h     # full usage
```

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
  preview) · **eza**, **gh**, **kubectl**, **htop**.

---

## Usage

`F11` / `F12` / `F24` — cycle colorschemes prev / next / shuffle. Everything else lives under
`,` (leader); press it and wait for the which-key popup. Function keys cover the common
actions — file explorer (`F1`), pickers (`F2`–`F6`), search-highlight toggle (`F10`).

In Zsh, `^S` triggers interactive fzf completion (file/dir picking via fzf + zoxide).

---

## Secret handling

No credentials live in this repository. API keys and tokens are read from the environment at
point of use; the values themselves come from an untracked `~/.env`, sourced late in shell
startup to limit exposure to child processes. The repo references variables — it never
defines them.

---

## Author

[Patrick DeYoreo](https://github.com/pxkdxo) — platform engineer (DevOps,
Cloudsud).
