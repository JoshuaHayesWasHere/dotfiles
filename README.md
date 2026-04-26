# dotfiles — Arch Linux

Personal dotfiles for Arch + Hyprland. Built on top of [JaKooLit's KooL Dots](https://github.com/JaKooLit/Hyprland-Dots) as a starting rice.

## Layout

```
bash/        bashrc, bash_profile
claude/      Claude Code settings + statusline
config/      Snapshot of ~/.config (Hyprland, waybar, kitty, nvim, etc.)
git/         gitconfig
keyd/        keyd remap config (symlinked to /etc/keyd/)
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
  fastfetch pokemon-colorscripts-git \
  aws-cli-v2
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

### 7. Keyboard remap (CapsLock as Super)

Maps Caps Lock to Super (the Win/Cmd key remains Super), and toggles real Caps Lock when both Shift keys are pressed together. System-wide via [keyd](https://github.com/rvaiya/keyd).

```bash
sudo pacman -S keyd
sudo ln -sf ~/dotfiles/keyd/default.conf /etc/keyd/default.conf
sudo systemctl enable --now keyd
```

Reload after editing the config: `sudo keyd reload`. Disable temporarily: `sudo systemctl stop keyd`.

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
| `cd`  | zoxide via `--cmd cd` | Standard `cd`, plus frecency fallback (`cd projectname`) |
| `ci`  | `cdi` | Interactive zoxide directory picker |

### Clipboard (Wayland)

| Command | Description |
|---------|-------------|
| `clip`  | Pipe stdin to the clipboard (`wl-copy`) |
| `dclip <cmd>` | Run `<cmd>`, print it and its output to the terminal, and copy both to the primary selection |

### Project shortcuts

| Alias | Command |
|-------|---------|
| `winnifred` | `python3 ~/repos/Winnifred/scripts/run-local.py` |

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
