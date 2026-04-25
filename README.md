# dotfiles

Personal dotfiles managed via symlinks.

## Setup

Each file in this repo is symlinked to its standard location in `$HOME`:

| Dotfile | Source |
|---------|--------|
| `~/.zshrc` | `zsh/zshrc` |
| `~/.p10k.zsh` | `zsh/p10k.zsh` |
| `~/.tmux.conf` | `tmux/tmux.conf` |
| `~/.gitconfig` | `git/gitconfig` |
| `~/.bashrc` | `bash/bashrc` |
| `~/.profile` | `bash/profile` |
| `~/.dircolors` | `shell/dircolors` |
| `~/.claude/settings.json` | `claude/settings.json` |
| `~/.claude/statusline.sh` | `claude/statusline.sh` |

---

## Tmux

Prefix: **`Ctrl-a`**

### Panes

| Action | Binding |
|--------|---------|
| Split right (vertical) | `prefix \|` |
| Split below (horizontal) | `prefix _` |
| Navigate left | `prefix h` |
| Navigate down | `prefix j` |
| Navigate up | `prefix k` |
| Navigate right | `prefix l` |
| Resize left | `prefix H` |
| Resize down | `prefix J` |
| Resize up | `prefix K` |
| Resize right | `prefix L` |

### Copy mode (vi)

| Action | Binding |
|--------|---------|
| Enter copy mode | `prefix [` |
| Begin selection | `v` |
| Yank selection | `y` |
| Cancel | `Escape` |

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
| `winnifred` | `python3 ~/scripts/runWinnifredFullstack.py` | Start Winnifred fullstack dev environment |

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
