# dotfiles

![macOS](https://img.shields.io/badge/macOS-000000?logo=apple&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black)
![Neovim](https://img.shields.io/badge/Neovim-57A143?logo=neovim&logoColor=white)

Keyboard-driven development environment for macOS and Linux.
Neovim · Zsh · Tmux · Starship · fzf — configured to work together.

<!-- screenshot: nvim with LSP, lualine, bufferline -->
![Neovim](.github/screenshots/nvim.png)

---

## Highlights

**Coordinated colorscheme system** — colorscheme definitions live in one place and propagate to every tool: Neovim, Alacritty, Kitty, Foot, bat, and `LS_COLORS` via vivid. Inside Neovim, a custom `Deque`/`Playlist` engine rotates through schemes at runtime (F11 / F12 / F24).

<!-- screenshot: colorscheme cycling (multiple frames or GIF) -->
![Colorscheme cycling](.github/screenshots/colorschemes.gif)

**AI-first editing stack** — [Avante.nvim](https://github.com/yetone/avante.nvim) drives agentic editing via `cursor-agent` (ACP), [MCPHub.nvim](https://github.com/ravitemer/mcphub.nvim) routes MCP tools into it (replacing Avante's built-in file/bash tools), and Copilot handles inline completions. On macOS, MCPHub runs as a launchd agent.

**Neovim works inside VSCode** — the entire config loads inside vscode-neovim with motion/editing plugins force-enabled and everything else gated behind `cond = vim.g.vscode == nil`. No separate VSCode config.

**Cross-platform** — XDG base-dir compliant throughout. macOS uses launchd for background services; Linux uses systemd user units. Shell startup chains (`zshenv` → `zprofile` → `zshrc`, `profile.d/`, `environment.d/`) are POSIX-portable.

---

## What's inside

| Tool | Config |
|---|---|
| **Neovim** | Lua · lazy.nvim · full LSP (mason) · nvim-cmp · Treesitter · Avante + MCPHub + Copilot |
| **Zsh** | Oh-My-Zsh (personal fork) · fzf bindings · zoxide · fast-syntax-highlighting · autosuggestions |
| **Tmux** | Vi keys · true-color · system clipboard · powerline status · mouse |
| **Starship** | Two-line prompt · git status · language versions · AWS context |
| **Terminals** | Alacritty (primary) · Kitty · Foot — coordinated colorschemes |
| **Git** | Aliases · delta diff · color config |
| **Bat / Ripgrep / Vivid** | Pager · search · `LS_COLORS` theming |
| **Yazi / Ranger** | Terminal file managers |

<!-- screenshot: tmux panes + starship prompt -->
![Terminal + Tmux](.github/screenshots/tmux.png)

---

## Installation

These files are designed to live at `~/.config` and load via the XDG spec.
Clone directly:

```sh
git clone --recurse-submodules https://github.com/pxkdxo/dotfiles ~/.config
```

Or use the install script to symlink individual files as `~/.*`:

```sh
git clone --recurse-submodules https://github.com/pxkdxo/dotfiles
cd dotfiles
./install-dotfiles.sh        # interactive — prompts before replacing
./install-dotfiles.sh -f     # force-replace
./install-dotfiles.sh -n     # dry run
```

**Neovim requires these on `$PATH`:**

```
node  yarn  rg  fzf  git  make  python3  cursor-agent
```

---

## Usage

`F11` / `F12` / `F24` — cycle colorschemes prev / next / shuffle. Everything else is under `,` (leader) — press it and wait for the which-key popup.

In Zsh: `^R` history search, `^S` interactive `cd` via fzf + zoxide.

---

## Author

[Patrick DeYoreo](https://github.com/pxkdxo) — DevOps / systems administration background.
