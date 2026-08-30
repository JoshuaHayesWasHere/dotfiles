# ~/dotfiles - notes for agents

Deliberate decisions in this repo. Do not silently revert them; the README
section named in each bullet has the full rationale.

- **The zsh three-file split** (`zsh/zshenv`, `zsh/functions.zsh`, `zsh/zshrc`)
  is intentional. See "How the zsh files split". `zshrc` returns early for agent
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
  treat it as privileged. See "RGB lighting" for the drift check and for the
  detection-runs-once failure mode that silently kills all HID lighting.
- **Wallpaper state files are runtime, not config.** `.wallpaper_current` and
  `.wallpaper_modified` are gitignored on purpose. See "Wallpaper". Do not track
  them.
- This rice sits on top of **JaKooLit's KooL Dots**. Many scripts under
  `config/hypr/` are upstream, not hand-written here. Match the surrounding
  file's style, and do not "fix" upstream quirks unless they actually break
  something.

## Maintaining this file

Keep it to things an agent would plausibly get wrong and undo. Point to the
README; do not duplicate it. Keep entries concise.
