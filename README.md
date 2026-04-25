# dotfiles — WSL / Ubuntu

Personal dotfiles for WSL2 (Ubuntu-based) environments.

## Setup

Clone the repo and create symlinks:

```bash
git clone https://github.com/JoshuaHayesWasHere/dotfiles.git ~/dotfiles
git checkout wsl-ubuntu

ln -s ~/dotfiles/zsh/zshrc ~/.zshrc
ln -s ~/dotfiles/zsh/p10k.zsh ~/.p10k.zsh
ln -s ~/dotfiles/git/gitconfig ~/.gitconfig
ln -s ~/dotfiles/bash/bashrc ~/.bashrc
ln -s ~/dotfiles/bash/profile ~/.profile
ln -s ~/dotfiles/shell/dircolors ~/.dircolors
mkdir -p ~/.claude
ln -s ~/dotfiles/claude/settings.json ~/.claude/settings.json
ln -s ~/dotfiles/claude/statusline.sh ~/.claude/statusline.sh
```

---

## Installation

### 1. Core tools

```bash
sudo apt update
sudo apt install zsh ripgrep bat eza zoxide
```

> `bat` ships as `batcat` on Ubuntu due to a naming conflict — the aliases in `.zshrc` already account for this.

### 2. Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 3. Powerlevel10k theme

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

### 4. Zsh plugins

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### 5. Nerd Font

Install a [Nerd Font](https://www.nerdfonts.com/) in your Windows terminal (e.g. MesloLGS NF) and set it as the default font. Required for `eza` icons and Powerlevel10k glyphs.

### 6. NVM (Node Version Manager)

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
```

### 7. Set zsh as default shell

```bash
chsh -s $(which zsh)
```

---

## Shell Aliases

### Modern CLI replacements

| Alias | Command | Description |
|-------|---------|-------------|
| `ls` | `eza --icons` | Directory listing with icons |
| `ll` | `eza -l --icons --git` | Long listing with git status |
| `la` | `eza -la --icons --git` | Long listing including hidden files |
| `lt` | `eza --tree --icons` | Tree view |
| `cat` | `batcat` | Syntax-highlighted file viewer |
| `bat` | `batcat` | Same as above |
| `grep` | `rg` | Fast search via ripgrep |
| `cd` | `z` | Smart directory jump via zoxide |
| `ci` | `zi` | Interactive zoxide directory picker |

### Project shortcuts

| Alias | Command | Description |
|-------|---------|-------------|
| `winnifred` | `python3 ~/projects/Winnifred/scripts/run-local.py` | Start Winnifred fullstack dev environment |

### AWS (SSO)

| Command | Description |
|---------|-------------|
| `awslogin <profile>` | Log in to an SSO profile and export it |
| `awsdev` | Log in to `sandbox` profile |
| `awsadmin` | Log in to `admin` profile |
| `awslrpdev` | Log in to `lrp-sandbox` profile |
| `awslrpadmin` | Log in to `lrp-admin` profile |
| `awswho` | Show current caller identity |
| `awslogout` | Log out of SSO and unset `AWS_PROFILE` |
