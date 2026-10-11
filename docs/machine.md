# Setting up the machine

Packages and system-level pieces that the configs here expect. The Setup
section of the README only creates links; everything below is done once by hand.

## Install yay (AUR helper)

```bash
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay && makepkg -si
```

## Install core CLI tools

```bash
yay -S zsh ripgrep bat eza fd zoxide fzf starship jq uv mise git-delta \
  ttf-meslo-nerd \
  fastfetch pokemon-colorscripts-git \
  wl-clipboard \
  aws-cli-v2
```

Oh My Zsh and its two extra plugins are not packages on this machine: the
framework comes from its own installer (below), and `zsh-autosuggestions` and
`zsh-syntax-highlighting` are cloned into `~/.oh-my-zsh/custom/plugins/`.

`jq` and `uv` are not optional: the Hyprland scripts and the quickshell
overview shell out to `jq`, and `winnifred` runs via `uv`.

**The desktop stack is assumed, not installed here.** Hyprland itself plus
`waybar`, `rofi`, `swaync`, `wlogout`, `quickshell`, `awww`, `hyprlock`,
`hypridle`, `hyprpolkitagent`, `grim`, `slurp`, `swappy`, `playerctl`,
`wireplumber` (`wpctl`), `cliphist`, `libnotify` and `libcanberra` must be
installed, along with `xdg-desktop-portal-hyprland` for screen sharing, and
`kvantum`, `qt5ct` and `qt6ct` for the Qt theme. The bar needs `waybar-git`
until the next waybar release (see `config/hypr/README.md`, which describes
the Hyprland config itself).

**Dictation is its own repo.** `Super+V` and the autostart call `voxtype` and
`dictation`, which `~/repos/dictation` installs and documents. Without it the
bind does nothing and the rest of the session is unaffected.

## Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
```

## NVM (Node Version Manager)

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
```

## Git credentials

```bash
yay -S github-cli
gh auth login
gh auth setup-git
```

## Set zsh as default shell

```bash
chsh -s $(which zsh)
```

## Keyboard remap (CapsLock as Super)

Maps Caps Lock to Super (the Win/Cmd key remains Super), and toggles real Caps Lock when both Shift keys are pressed together. System-wide via [keyd](https://github.com/rvaiya/keyd).

```bash
sudo pacman -S keyd
sudo ln -sf ~/dotfiles/keyd/default.conf /etc/keyd/default.conf
sudo systemctl enable --now keyd
```

Reload after editing the config: `sudo keyd reload`. Disable temporarily: `sudo systemctl stop keyd`.

## SDDM greeter monitor layout

`config/sddm/Xsetup` arranges the greeter's monitors with `xrandr` to match
`config/hypr/monitors.lua`, so the login screen is not laid out differently
from the session. The output names and positions are specific to this desk.

```bash
sudo mkdir -p /etc/sddm/scripts /etc/sddm.conf.d
sudo ln -sfn ~/dotfiles/config/sddm/Xsetup /etc/sddm/scripts/Xsetup
printf '[X11]\nDisplayCommand=/etc/sddm/scripts/Xsetup\n' | sudo tee /etc/sddm.conf.d/10-monitors.conf
```

## RGB lighting

OpenRGB has its own page: [openrgb.md](openrgb.md).

## Keeping the machine healthy

This box is a daily dev machine and the home lab hub, so a few things watch it:

| What | Where | Does |
|------|-------|------|
| `hub-watch.timer` | `systemd/user/` | Every 5 minutes: failed units (system and user) and dead, restart-looping or unhealthy containers. One desktop notification when the set of problems changes, one when it clears |
| `hub-watch-deep.timer` | `systemd/user/` | Daily: the same, plus every CRIT finding from `aa check` |
| `docker-prune.timer` | `systemd/user/` | Weekly: dangling images, build cache older than a week, and unused images built here that were last built or tagged over 14 days ago (`systemd/docker-prune-built`; pulled images are kept) |
| `treehouse-prune.timer` | `systemd/user/` | Weekly: `treehouse prune --all --yes`, which removes only worktrees that are merged, clean and idle |
| `earlyoom` | `/etc/default/earlyoom` | Kills the largest process before memory runs out, never the session or the hub daemons |
| `smartd` | package default | Watches the NVMe's SMART health |
| Docker log limits | `/etc/docker/daemon.json` | `max-size` 10m, 3 files, for containers created after the daemon next restarts |
| `linux-lts` | `/etc/mkinitcpio.d/linux-lts.preset` | A second signed UKI, `arch-linux-lts.efi`, as a fallback kernel |

```bash
yay -S earlyoom smartmontools linux-lts
sudo systemctl enable --now earlyoom smartd reflector.timer
```

The boot menu is hidden (`timeout 0`), so to boot the fallback kernel once:
`systemctl reboot --boot-loader-entry=arch-linux-lts.efi`.

## Git and SSH

`git/config` rebases on pull, remembers conflict resolutions (`rerere`), sets
the upstream on first push, and pages diffs through `delta`. HTTPS credentials
for GitHub come from `gh` (`gh auth login` once), not a plaintext store.

`ssh-agent` runs as a systemd user unit and `zshenv` exports its socket. Add
`AddKeysToAgent yes` to `~/.ssh/config` so a key is unlocked once per login.

## Wallpaper

The current wallpaper is **runtime state, not config**: a symlink at
`~/.local/state/hypr/wallpaper`, outside this repo, maintained by
`config/hypr/scripts/wallpaper`. Images are read from `~/Pictures/wallpapers`.

On a fresh machine the symlink does not exist yet, so **pick a wallpaper on
first login** with `Super+End`. Until then the desktop comes up bare and the
lock screen falls back to a plain colour; nothing breaks.
