# Custom Vivid Themes

These themes are adapted from the colorschemes in this repository (iTerm2-Color-Schemes, tokyonight.nvim).

## Available Themes

| Theme | Source |
|-------|--------|
| `atom-one-dark` | Atom One Dark (iTerm2-Color-Schemes) |
| `atom-one-light` | Atom One Light (iTerm2-Color-Schemes) |
| `gruvbox-dark` | Gruvbox Dark (iTerm2-Color-Schemes) |
| `catppuccin-mocha` | Catppuccin Mocha (iTerm2-Color-Schemes) |
| `tokyonight-night` | Tokyo Night (tokyonight.nvim) |
| `dracula` | Dracula (iTerm2-Color-Schemes) |
| `nord` | Nord (iTerm2-Color-Schemes) |
| `rose-pine` | Rose Pine (iTerm2-Color-Schemes) |
| `kanagawa-wave` | Kanagawa Wave (iTerm2-Color-Schemes) |
| `everforest-dark` | Everforest Dark Hard (iTerm2-Color-Schemes) |
| `carbonfox` | Carbonfox (iTerm2-Color-Schemes) |
| `cyberpunk` | Cyberpunk (iTerm2-Color-Schemes) |
| `cyberdyne` | Cyberdyne (iTerm2-Color-Schemes) |
| `kanso-pearl` | Kanso Pearl (iTerm2-Color-Schemes) |
| `xcode-dark-hc` | Xcode Dark hc (iTerm2-Color-Schemes) |
| `borland` | Borland (iTerm2-Color-Schemes) |
| `kurokula` | Kurokula (iTerm2-Color-Schemes) |
| `poimandres` | Poimandres (iTerm2-Color-Schemes) |
| `flexoki-dark` | Flexoki Dark (iTerm2-Color-Schemes) |
| `nightfox` | Nightfox (iTerm2-Color-Schemes) |
| `terafox` | Terafox (iTerm2-Color-Schemes) |
| `synthwave` | Synthwave (iTerm2-Color-Schemes) |
| `vesper` | Vesper (iTerm2-Color-Schemes) |
| `andromeda` | Andromeda (iTerm2-Color-Schemes) |
| `embark` | Embark (iTerm2-Color-Schemes) |
| `miasma` | Miasma (iTerm2-Color-Schemes) |

## Usage

Use the full path to generate LS_COLORS:

```sh
export LS_COLORS="$(vivid generate /Users/patrick.deyoreo/.local/etc/colorschemes/vivid/atom-one-dark.yml)"
```

Or copy themes to `~/.config/vivid/themes/` and use by name:

```sh
cp atom-one-dark.yml ~/.config/vivid/themes/
export LS_COLORS="$(vivid generate atom-one-dark)"
```

## Also Available

- `cyberdream` / `cyberdream-light` — from cyberdream.nvim (symlinked)
