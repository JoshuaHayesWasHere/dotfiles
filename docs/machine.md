# Setting up the machine

`bootstrap` sets up everything on this page on a fresh archinstall system, and
it holds the one package list. This page explains the parts the script does
not make obvious.

## Packages

`bootstrap` builds `yay` from the AUR, then installs everything through it.
The parts that are easy to get wrong:

- **Sound needs `pipewire-audio`.** It carries PipeWire's ALSA plugin; without
  it WirePlumber finds no sound cards at all, even though ALSA sees them.
  `pipewire-pulse` serves the many apps (browsers included) that speak the
  PulseAudio API.
- **`jq` and `uv` are not optional**: the Hyprland scripts and the quickshell
  overview shell out to `jq`, and `winnifred` runs via `uv`.
- **The bar needs `waybar-git`** until the next waybar release (see
  `config/hypr/README.md`, which describes the Hyprland config itself).
- **Oh My Zsh and its two extra plugins are not packages**: the framework comes
  from its own installer, and `zsh-autosuggestions` and
  `zsh-syntax-highlighting` are cloned into `~/.oh-my-zsh/custom/plugins/`.
- **Node comes from mise**, not a package. `config/mise/config.toml` names the
  version and mise's shims put it on `PATH` for every shell, agent shells
  included. Global npm tools install into it, among them `gh-axi`, which a
  Claude Code `SessionStart` hook runs.
- **Dictation is its own repo.** `Super+V` and the autostart call `voxtype` and
  `dictation`, which `~/repos/dictation` installs and documents. Without it the
  bind does nothing and the rest of the session is unaffected.

## System tuning

| File | Why |
|------|-----|
| `/etc/makepkg.conf.d/local.conf` | AUR builds use every core (`MAKEFLAGS`) and skip the `-debug` split packages Arch's default `makepkg.conf` turns on |
| `/etc/sysctl.d/99-vm-zram-parameters.conf` | Swap is zram only, so the Arch wiki's zram values apply (`vm.swappiness = 180`, `vm.page-cluster = 0`) |
| `/etc/pacman.conf` | `ParallelDownloads = 10` |
| `/etc/xdg/reflector/reflector.conf` | `--country US`, so the weekly mirror refresh does not pick mirrors abroad |

`yay` runs with `--removemake`, so build-only dependencies (rust, clang, cmake)
do not linger as orphans.

## Keyboard remap (CapsLock as Super)

Maps Caps Lock to Super (the Win/Cmd key remains Super), and toggles real Caps Lock when both Shift keys are pressed together. System-wide via [keyd](https://github.com/rvaiya/keyd), with `keyd/default.conf` linked to `/etc/keyd/default.conf`.

Reload after editing the config: `sudo keyd reload`. Disable temporarily: `sudo systemctl stop keyd`.

## SDDM greeter monitor layout

`config/sddm/Xsetup` arranges the greeter's monitors with `xrandr` to match
`config/hypr/monitors.lua`, so the login screen is not laid out differently
from the session. The output names and positions are specific to this desk.
`bootstrap` links it to `/etc/sddm/scripts/Xsetup` and points
`/etc/sddm.conf.d/10-monitors.conf` at it.

## Keeping the machine healthy

This box is a daily dev machine and the home lab hub, so a few things watch it:

| What | Where | Does |
|------|-------|------|
| `hub-watch.timer` | `systemd/user/` | Every 5 minutes: failed units (system and user) and dead, restart-looping or unhealthy containers. One desktop notification when the set of problems changes, one when it clears |
| `hub-watch-deep.timer` | `systemd/user/` | Daily: the same, plus every CRIT finding from `aa check` |
| `docker-prune.timer` | `systemd/user/` | Weekly: dangling images and build cache older than a week |
| `earlyoom` | `/etc/default/earlyoom` | Kills the largest process before memory runs out, never the session or the hub daemons |
| `smartd` | package default | Watches the NVMe's SMART health |
| Docker log limits | `/etc/docker/daemon.json` | `max-size` 10m, 3 files, for containers created after the daemon next restarts |
| `paccache.timer` | `pacman-contrib` | Weekly: trims the package cache to the last three versions of each package |
| `linux-lts` | `/etc/mkinitcpio.d/linux-lts.preset` | A second UKI, `arch-linux-lts.efi`, as a fallback kernel. The preset must exist before the package is installed (`bootstrap` derives it from `linux.preset`), or the kernel is built as a plain initramfs that never shows up in the boot menu |

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
