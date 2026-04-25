# dotfiles

Personal dotfiles for zsh-based environments. Managed via symlinks.

## Branches

| Branch | Environment |
|--------|-------------|
| `wsl-ubuntu` | WSL2 on Windows (Ubuntu-based) |
| `arch` | Arch Linux (or Arch-based distros) |

Clone the repo and check out the branch for your environment:

```bash
git clone https://github.com/JoshuaHayesWasHere/dotfiles.git ~/dotfiles
cd ~/dotfiles
git checkout wsl-ubuntu   # or: git checkout arch
```

Each branch has its own README with installation instructions and symlink setup.

---

## Tools

| Tool | Purpose |
|------|---------|
| [zsh](https://www.zsh.org/) | Shell |
| [oh-my-zsh](https://ohmyz.sh/) | Zsh plugin/theme manager |
| [Powerlevel10k](https://github.com/romkatv/powerlevel10k) | Prompt theme |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Fish-style inline suggestions |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Shell syntax coloring |
| [eza](https://github.com/eza-community/eza) | Modern `ls` replacement |
| [bat](https://github.com/sharkdp/bat) | Syntax-highlighted `cat` replacement |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast `grep` replacement |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` replacement |
| [nvm](https://github.com/nvm-sh/nvm) | Node version manager |

---

## Aliases

**Drop-in replacements** (same command name, different engine)

| Command | Powered by |
|---------|------------|
| `ls` | eza |
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
