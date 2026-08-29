# dotfiles — Arch Linux

Personal dotfiles for Arch + Hyprland. Built on top of [JaKooLit's KooL Dots](https://github.com/JaKooLit/Hyprland-Dots) as a starting rice.

## Layout

```
bash/        bashrc, bash_profile
claude/      Claude Code settings, statusline, global CLAUDE.md
config/      ~/.config subtrees (Hyprland, waybar, kitty, nvim, etc.)
git/         gitconfig, global ignore
gtk/         gtkrc-2.0 (GTK2; GTK3/4 live under config/)
keyd/        keyd remap config (symlinked to /etc/keyd/)
openrgb/     RGB profile (symlinked to /etc/openrgb/)
shell/       dircolors
zsh/         zshenv (env + PATH), zshrc (interactive only), functions.zsh (portable helpers)
```

### How the zsh files split

Three files, loaded in different circumstances — this split is deliberate:

| File | Loads for | Holds |
|------|-----------|-------|
| `zsh/zshenv` | **every** zsh: login, scripts, agent/automation shells | `GOPATH`, `NVM_DIR`, `HISTFILE`, `PATH`, then sources `functions.zsh` |
| `zsh/functions.zsh` | **every** zsh (via zshenv) | `awslogin` & friends, `clip`/`dclip`, `winnifred` |
| `zsh/zshrc` | **interactive human shells only** | Oh My Zsh + plugins, Starship, `nvm.sh`, zoxide, greeting, the eza/bat/rg aliases |

`zshrc` returns early when `$CLAUDECODE` or `$AI_AGENT` is set. Claude Code snapshots
the shell before every command it runs, and inheriting the full interactive
environment meant coreutils were shadowed by tools with incompatible flags
(`ls` → `eza`, `cat` → `bat`) and `cd` was rerouted through zoxide's frecency
matching. Agent shells now start in ~1 ms with 2 aliases instead of ~225 ms with
275, while `eza`/`bat`/`rg`/`fd`/`jq`/`node`/`uv` remain on `PATH` under their
real names.

Put env and `PATH` in `zshenv`, anything portable in `functions.zsh`, and only
interactive weight in `zshrc`.

## Setup

Clone the repo and create symlinks:

```bash
git clone https://github.com/JoshuaHayesWasHere/dotfiles.git ~/dotfiles
cd ~/dotfiles && git checkout arch

# Shell + git
mkdir -p ~/.config/git
ln -sf ~/dotfiles/zsh/zshenv         ~/.zshenv
ln -sf ~/dotfiles/zsh/zshrc          ~/.zshrc
ln -sf ~/dotfiles/bash/bashrc        ~/.bashrc
ln -sf ~/dotfiles/bash/bash_profile  ~/.bash_profile
ln -sf ~/dotfiles/git/config         ~/.config/git/config
ln -sf ~/dotfiles/git/ignore         ~/.config/git/ignore
ln -sf ~/dotfiles/shell/dircolors    ~/.dircolors
ln -sf ~/dotfiles/gtk/gtkrc-2.0      ~/.gtkrc-2.0

# Starship prompt
mkdir -p ~/.config
ln -sf ~/dotfiles/starship/starship.toml ~/.config/starship.toml

# Claude Code
mkdir -p ~/.claude
ln -sf ~/dotfiles/claude/settings.json  ~/.claude/settings.json
ln -sf ~/dotfiles/claude/statusline.sh  ~/.claude/statusline.sh
ln -sf ~/dotfiles/claude/CLAUDE.md      ~/.claude/CLAUDE.md

# ~/.config — symlink each tracked subtree
mkdir -p ~/.config
for d in hypr waybar rofi wlogout swaync swappy wallust kitty nvim btop cava \
         fastfetch qalculate Kvantum qt5ct qt6ct gtk-3.0 gtk-4.0 nwg-look \
         nwg-displays xsettingsd Thunar quickshell fontconfig htop; do
  ln -sfn ~/dotfiles/config/$d ~/.config/$d
done
ln -sf ~/dotfiles/config/mimeapps.list    ~/.config/mimeapps.list
ln -sf ~/dotfiles/config/user-dirs.dirs   ~/.config/user-dirs.dirs
ln -sf ~/dotfiles/config/user-dirs.locale ~/.config/user-dirs.locale
```

## Installation

### 1. Install yay (AUR helper)

```bash
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay && makepkg -si
```

### 2. Install core CLI tools

```bash
yay -S zsh ripgrep bat eza fd zoxide fzf starship jq uv \
  oh-my-zsh-git \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  ttf-meslo-nerd \
  fastfetch pokemon-colorscripts-git \
  wl-clipboard \
  aws-cli-v2
```

`jq` and `uv` are not optional: 27 tracked files shell out to `jq` (including
`hypr/scripts/WorkspaceOnMonitor.sh`), and `winnifred` runs via `uv`.

**The desktop stack is assumed, not installed here.** Hyprland itself plus
`waybar`, `rofi`, `swaync`, `awww`, `grim`, `slurp`, `playerctl`, `pamixer`,
`brightnessctl`, `cliphist` and friends come from
[JaKooLit's KooL Dots](https://github.com/JaKooLit/Hyprland-Dots) installer —
run that first, then lay these dotfiles over the top.

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
yay -S github-cli
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

### 8. RGB lighting (OpenRGB)

The daemon runs as `openrgb --server --config /etc/openrgb --profile default`, so
the profile that matters lives in **`/etc/openrgb/`**, not `~/.config/OpenRGB`
(that one is only the GUI's scratch directory and is deliberately untracked).

```bash
yay -S openrgb
sudo ln -sfn ~/dotfiles/openrgb/default.orp /etc/openrgb/default.orp
```

**Watch for drift.** Unlike keyd, OpenRGB rewrites its own config files when you
save a profile, and it replaces rather than edits in place — which can clobber
the symlink and leave `/etc/openrgb/default.orp` as a regular file while the repo
copy silently goes stale. After saving a profile in the GUI, check it:

```bash
ls -l /etc/openrgb/default.orp     # want: -> ~/dotfiles/openrgb/default.orp
```

If it came back as a regular file, fold the change in and relink:

```bash
sudo cp /etc/openrgb/default.orp ~/dotfiles/openrgb/default.orp
sudo chown $USER:$USER ~/dotfiles/openrgb/default.orp
sudo ln -sfn ~/dotfiles/openrgb/default.orp /etc/openrgb/default.orp
```

---

## Shell aliases

### Modern CLI replacements

Interactive shells only — see [How the zsh files split](#how-the-zsh-files-split).
Agent shells get plain coreutils and call `eza`/`bat`/`rg` by name.

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

| Command | Runs |
|---------|------|
| `winnifred` | `uv run ~/repos/Winnifred/scripts/run-local.py` (function — args pass through) |
| `aa` | `uv run --project ~/repos/archaholics-anonymous aa` — an alias until the tool has earned a spot on `PATH`; graduating means `uv tool install --editable` (shim into `~/.local/bin`) and dropping the alias |
| `cl` | `claude` (launch Claude Code) |
| `claude` | Shell function, not the bare binary: launched from a bare `$HOME` it runs the session in `~/desk` (a persistently-trusted workspace, since `$HOME` itself cannot hold trust). Anywhere else it behaves exactly like `claude`. |

### System (dual-boot)

Defined in `zshrc`, not `functions.zsh`, on purpose: both need a TTY to prompt,
and agent shells have no business holding a one-word reboot command.

| Command | Description |
|---------|-------------|
| `windows` | Reboot into Windows **once**. Sets a UEFI one-shot entry the firmware consumes and clears itself, so `BootOrder` is never touched. Looks the entry up by name — Windows updates and NVRAM resets renumber `BootXXXX`. |
| `bios` | Reboot straight into BIOS setup, bypassing Fast Boot's ~1s keyboard window. |

Both run `sudo -k` first to drop any cached credential, so a recent unrelated
`sudo` can never let a stray keystroke reboot the machine; the confirmation is
folded into that password prompt.

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

---

## Wallpaper

`config/hypr/wallpaper_effects/.wallpaper_current` and `.wallpaper_modified` are
**runtime state, not config** — they are the live wallpaper bitmaps, rewritten
(megabytes at a time) on every wallpaper change, so they are gitignored.

Eight tracked files read `.wallpaper_current` (hyprlock, the SDDM wallpaper
script, `RestoreWallpaper.sh`, the wallust theming scripts). On a fresh clone it
does not exist yet, so **pick a wallpaper on first login** with the KooL Dots
wallpaper picker (`hypr/UserScripts/WallpaperSelect.sh`); everything downstream
regenerates from it. `RestoreWallpaper.sh` exits cleanly when the file is
missing, so nothing breaks in the meantime — the desktop just comes up bare.
