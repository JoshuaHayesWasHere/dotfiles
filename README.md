# dotfiles — Arch Linux

Personal dotfiles for Arch-based environments.

## Setup

Clone the repo and create symlinks:

```bash
git clone https://github.com/JoshuaHayesWasHere/dotfiles.git ~/dotfiles
git checkout arch

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

### 1. Install paru (AUR helper)

```bash
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/paru.git /tmp/paru
cd /tmp/paru && makepkg -si
```

### 2. Install core tools

```bash
paru -S zsh ripgrep bat eza zoxide \
  oh-my-zsh-git \
  zsh-theme-powerlevel10k-git \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  ttf-meslo-nerd
```

> On Arch, `bat` is the binary name (not `batcat`). The aliases in `.zshrc` already use `bat`.

### 3. Oh My Zsh (if not using the AUR package)

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

If you installed `oh-my-zsh-git` via paru, symlink the Powerlevel10k theme into the custom themes directory:

```bash
ln -s /usr/share/zsh-theme-powerlevel10k \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
```

### 4. NVM (Node Version Manager)

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
```

### 5. Git credentials

Use `gh` (GitHub CLI) or `git-credential-libsecret`:

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

## Shell Aliases

### Modern CLI replacements

| Alias | Command | Description |
|-------|---------|-------------|
| `ls` | `eza --icons` | Directory listing with icons |
| `ll` | `eza -l --icons --git` | Long listing with git status |
| `la` | `eza -la --icons --git` | Long listing including hidden files |
| `lt` | `eza --tree --icons` | Tree view |
| `cat` | `bat` | Syntax-highlighted file viewer |
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
