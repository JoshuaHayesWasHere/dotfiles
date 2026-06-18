# dotfiles — macOS

Personal dotfiles for macOS. Tooling adapted from the [`arch`](../../tree/arch)
branch (Starship, modern CLI replacements, AWS helpers, Neovim), with
Linux-specific bits converted to their macOS equivalents.

## Layout

```
bash/        bashrc, bash_profile
claude/      Claude Code settings + statusline
config/      Snapshot of ~/.config (currently: nvim)
git/         gitconfig
shell/       dircolors
starship/    starship.toml prompt config
tmux/        tmux.conf
zsh/         zshrc
```

## Setup

Clone the repo and create symlinks:

```bash
git clone git@github.com:JoshuaHayesWasHere/dotfiles.git ~/dotfiles
cd ~/dotfiles && git checkout mac

# Shell + git
ln -sf ~/dotfiles/zsh/zshrc          ~/.zshrc
ln -sf ~/dotfiles/bash/bashrc        ~/.bashrc
ln -sf ~/dotfiles/bash/bash_profile  ~/.bash_profile
ln -sf ~/dotfiles/git/gitconfig      ~/.gitconfig
ln -sf ~/dotfiles/shell/dircolors    ~/.dircolors
ln -sf ~/dotfiles/tmux/tmux.conf     ~/.tmux.conf

# Starship prompt
mkdir -p ~/.config
ln -sf ~/dotfiles/starship/starship.toml ~/.config/starship.toml

# Neovim
ln -sfn ~/dotfiles/config/nvim ~/.config/nvim

# Claude Code
mkdir -p ~/.claude
ln -sf ~/dotfiles/claude/settings.json  ~/.claude/settings.json
ln -sf ~/dotfiles/claude/statusline.sh  ~/.claude/statusline.sh
```

## Tools

| Tool | Purpose |
|------|---------|
| [zsh](https://www.zsh.org/) + [oh-my-zsh](https://ohmyz.sh/) | Shell + plugin manager |
| [Starship](https://starship.rs/) | Cross-shell prompt (replaces Powerlevel10k) |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Inline suggestions |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Shell syntax coloring |
| [eza](https://github.com/eza-community/eza) | Modern `ls` replacement |
| [bat](https://github.com/sharkdp/bat) | Syntax-highlighted `cat` |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast `grep` |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder (CTRL-R history) |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` |
| [Neovim](https://neovim.io/) | Editor (lazy.nvim config; requires 0.11+) |
| [nvm](https://github.com/nvm-sh/nvm) / [rbenv](https://github.com/rbenv/rbenv) | Node / Ruby version managers |

## Aliases

**Drop-in replacements** (same command name, different engine)

| Command | Powered by |
|---------|------------|
| `ls` | eza (falls back to `ls -G` if eza absent) |
| `cat` | bat |
| `grep` | ripgrep |
| `cd` | zoxide |

**New shortcuts**

| Alias | Expands to | Powered by |
|-------|------------|------------|
| `ll` | `ls -l` | eza |
| `la` | `ls -la` | eza |
| `lt` | `tree` | eza |
| `ci` | *(interactive chooser)* | zoxide |
| `clip` | `pbcopy` | macOS pasteboard |
| `cl` | `claude` | Claude Code |

## Installing the CLI tools on macOS

On older macOS releases Homebrew is a "Tier 2" config with no prebuilt bottles
(it compiles from source), so these are installed as prebuilt binaries into
`~/.local/bin` (which `zsh/zshrc` prepends to `PATH`):

- **starship, bat, fzf, zoxide** — prebuilt binaries from each project's GitHub releases.
- **eza** — no macOS prebuilt binary exists; build with `cargo install eza`
  (needs a recent Rust toolchain: `rustup update stable`).
- **Neovim** — prebuilt `nvim-macos-x86_64.tar.gz` (the config needs 0.11+).
- **tree-sitter CLI** — prebuilt binary; required by nvim-treesitter's `main`
  branch to build parsers (`tree-sitter build`).

## macOS adaptations vs. the `arch` branch

- Clipboard: `wl-copy` → `pbcopy`
- `dircolors` → `gdircolors` (from coreutils)
- Native `ls -G` / `CLICOLOR` fallback when `eza` is absent
- Dropped Arch-only pieces: `archlinux` OMZ plugin, pokemon-colorscripts/fastfetch
  greeting, Hyprland/waybar/keyd and other desktop configs
