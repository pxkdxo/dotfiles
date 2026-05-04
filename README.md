# dotfiles

Personal configuration files for a Linux/macOS development environment,
emphasizing a keyboard-driven workflow built around Neovim, Zsh, and Tmux.

---

## What's inside

| Tool | Notes |
|---|---|
| **Neovim** | Lua config via lazy.nvim · full LSP (mason) · nvim-cmp · Treesitter · AI-assisted editing (Copilot, Avante, MCP) |
| **Zsh** | Oh-My-Zsh · fzf key-bindings · zoxide · fast-syntax-highlighting · zsh-autosuggestions |
| **Tmux** | Vi key-bindings · true-color · system clipboard · powerline status |
| **Starship** | Two-line prompt with git status, language versions, and AWS context |
| **Alacritty / Kitty / Foot** | Terminal configs with coordinated colorschemes |
| **Bat / Ripgrep / Vivid** | Pager, search, and `LS_COLORS` theming |
| **Yazi / Ranger** | Terminal file manager configs |
| **Git** | Aliases, color config, and a handful of useful one-liners |

---

## Installation

These files are designed to live in `~/.config` and be loaded via the XDG
base-directory spec.  Clone the repository directly into that directory:

```sh
git clone https://github.com/pxkdxo/dotfiles ~/.config
```

> **Note:** This replaces your existing `~/.config`.  Back it up first, or
> clone elsewhere and merge selectively.

Alternatively, use the included install script to symlink individual config
files into your home directory as hidden files:

```sh
git clone https://github.com/pxkdxo/dotfiles
cd dotfiles
./install-dotfiles.sh        # interactive mode (prompts before replacing)
./install-dotfiles.sh -f     # force-replace existing files
./install-dotfiles.sh -n     # dry run (never replace)
./install-dotfiles.sh -h     # full usage
```

---

## Author

[**Patrick DeYoreo**](https://github.com/pxkdxo) — background in DevOps and
systems administration.

- [LinkedIn](https://linkedin.com/in/patrickdeyoreo)
- [Twitter / X](https://twitter.com/deyoreopatrick)
