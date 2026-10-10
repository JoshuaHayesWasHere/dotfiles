# ~/dotfiles - notes for agents

Deliberate decisions in this repo. Do not silently revert them; the page
named in each bullet has the full rationale.

- **This repo is public.** Names of private repos, AWS organizations, profiles
  and hosts stay out of it. AWS organizations live in the untracked
  `~/.config/aws-orgs.zsh`; the live `claude/settings.json` is gitignored and
  `claude/settings.example.json` is the published copy, so mirror any setting
  worth showing there by hand. Stage files by name: `git add <dir>` has swept
  runtime state into a commit before.
- **The zsh three-file split** (`zsh/zshenv`, `zsh/functions.zsh`, `zsh/zshrc`)
  is intentional. See "How the zsh files split" in `docs/shell.md`. `zshrc` returns early for agent
  shells on purpose. Do not move interactive weight into `zshenv`, and do not add
  aliases that shadow coreutils anywhere an agent shell would source them.
- **GRUB is not the bootloader on this machine.** systemd-boot is. Editing
  `/etc/default/grub` changes nothing. See the "Boot setup" section in the global
  `~/.claude/CLAUDE.md` before touching anything boot-related.
- **OpenRGB's live setup is four symlinks into `openrgb/` here**: the profile
  `/etc/openrgb/default.orp`, the `ExecStartPost` hook
  `/usr/local/bin/openrgb-restore-lighting`, and both `openrgb.service.d`
  drop-ins. The GUI rewrites and replaces the profile, which clobbers that
  symlink. Root executes the hook script out of this user-writable repo, so
  treat it as privileged. See `docs/openrgb.md` for the drift check and for the
  detection-runs-once failure mode that silently kills all HID lighting.
- **Hyprland is configured in Lua** (`config/hypr`, see its README). Under a
  Lua config the legacy `hyprctl dispatch workspace 3` form does not parse:
  anything that dispatches from outside (waybar, swaync, wlogout, quickshell,
  scripts) must send a Lua expression, e.g.
  `hyprctl dispatch 'hl.dsp.focus({ workspace = 3 })'`.
- **Scripts under `config/hypr/scripts` are POSIX `sh`.** Check them with
  `shellcheck -s sh`.
- **`docs/keybinds.md` is generated.** After changing a bind, regenerate it with
  `config/hypr/scripts/keybinds markdown > docs/keybinds.md` (needs the running
  session). CI runs the other checks; `.github/workflows/check.yml` lists them.
- **Never retype Nerd Font icon glyphs** (waybar, swaync). They are
  private-use characters that do not survive retyping; move them with a tool.
- **Every theme here is written for this repo**: rofi, swaync, wlogout, kitty
  and the quickshell overview all take their colours from Catppuccin Mocha
  (kitty and tmux use Frappe). Do not paste in a theme from another dotfiles
  project; the only third-party files are the official Catppuccin themes for
  Kvantum and btop, which are MIT and credited in the README.
- **Try a look change off-screen first.** `docs/screenshots/README.md` describes
  the headless test desktop the screenshots are taken on; it renders the config
  without touching the real session.
- **Shell helpers have a check.** After editing `zsh/functions.zsh`, run
  `zsh zsh/functions.test.zsh`. It stubs `aws`, so it never signs in for real.

## Maintaining this file

Keep it to things an agent would plausibly get wrong and undo. Point to the
docs; do not duplicate them. Keep entries concise.
