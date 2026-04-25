# dotfiles — Arch Linux

Personal dotfiles for Arch + Hyprland. Built on top of [JaKooLit's KooL Dots](https://github.com/JaKooLit/Hyprland-Dots) as a starting rice.

## Layout

```
bash/        bashrc, bash_profile
claude/      Claude Code settings + statusline
config/      Snapshot of ~/.config (Hyprland, waybar, kitty, nvim, etc.)
git/         gitconfig
shell/       dircolors
zsh/         zshrc
```

## Setup

Clone the repo and create symlinks:

```bash
git clone https://github.com/JoshuaHayesWasHere/dotfiles.git ~/dotfiles
cd ~/dotfiles && git checkout arch

# Shell + git
ln -sf ~/dotfiles/zsh/zshrc          ~/.zshrc
ln -sf ~/dotfiles/bash/bashrc        ~/.bashrc
ln -sf ~/dotfiles/bash/bash_profile  ~/.bash_profile
ln -sf ~/dotfiles/git/gitconfig      ~/.gitconfig
ln -sf ~/dotfiles/shell/dircolors    ~/.dircolors

# Claude Code
mkdir -p ~/.claude
ln -sf ~/dotfiles/claude/settings.json  ~/.claude/settings.json
ln -sf ~/dotfiles/claude/statusline.sh  ~/.claude/statusline.sh

# ~/.config — symlink each tracked subtree
mkdir -p ~/.config
for d in hypr waybar rofi wlogout swaync swappy wallust kitty nvim btop cava \
         fastfetch qalculate Kvantum qt5ct qt6ct gtk-3.0 gtk-4.0 nwg-look \
         nwg-displays xsettingsd Thunar quickshell; do
  ln -sfn ~/dotfiles/config/$d ~/.config/$d
done
ln -sf ~/dotfiles/config/mimeapps.list    ~/.config/mimeapps.list
ln -sf ~/dotfiles/config/user-dirs.dirs   ~/.config/user-dirs.dirs
ln -sf ~/dotfiles/config/user-dirs.locale ~/.config/user-dirs.locale
```

## Installation

### 1. Install paru (AUR helper)

```bash
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/paru.git /tmp/paru
cd /tmp/paru && makepkg -si
```

### 2. Install core CLI tools

```bash
paru -S zsh ripgrep bat eza zoxide fzf \
  oh-my-zsh-git \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  ttf-meslo-nerd \
  fastfetch pokemon-colorscripts-git
```

### 3. Oh My Zsh (if not using AUR package)

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 4. NVM (Node Version Manager)

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
```

### 5. Git credentials

```bash
paru -S github-cli
gh auth login
gh auth setup-git
```

### 6. Set zsh as default shell

```bash
chsh -s $(which zsh)
```

---

## Shell aliases

### Modern CLI replacements

| Alias | Command | Description |
|-------|---------|-------------|
| `ls`  | `eza --icons` | Directory listing with icons |
| `ll`  | `eza -l --icons --git` | Long listing with git status |
| `la`  | `eza -la --icons --git` | Long listing including hidden files |
| `lt`  | `eza --tree --icons` | Tree view |
| `cat` | `bat` | Syntax-highlighted file viewer |
| `grep`| `rg` | Fast search via ripgrep |
| `cd`  | `z` | Smart directory jump via zoxide |
| `ci`  | `zi` | Interactive zoxide directory picker |

### Project shortcuts

| Alias | Command |
|-------|---------|
| `winnifred` | `python3 ~/projects/Winnifred/scripts/run-local.py` |

### AWS (SSO)

| Command | Description |
|---------|-------------|
| `awslogin <profile>` | Log in to an SSO profile and export it |
| `awsdev`     | Log in to `sandbox` |
| `awsadmin`   | Log in to `admin` |
| `awslrpdev`  | Log in to `lrp-sandbox` |
| `awslrpadmin`| Log in to `lrp-admin` |
| `awswho`     | Show current caller identity |
| `awslogout`  | Log out of SSO and unset `AWS_PROFILE` |
