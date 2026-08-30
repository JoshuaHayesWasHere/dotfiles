# Global preferences

- **Python: use `uv`** (`uv run`, `uv add`, `uv sync`, `uv venv`). Never `pip install`, `python -m venv`, or `source .../activate`.
- **Local utilities: build them as `uv` projects**, never loose `python foo.py` scripts. Throwaway one-offs may sit in `~/desk`; anything with a name and a git repo gets its own top-level `~/repos/<name>`. Run it as a **zsh alias** (`alias aa='uv run --project "$HOME/repos/<name>" aa'` in `~/dotfiles/zsh/zshrc`) until it has earned a spot on `PATH`. **Graduating** is `uv tool install --editable <path>`: the entry-point shim lands in `~/.local/bin` while the code still runs live from the source tree; drop the alias at that point. `uv tool list` / `uv tool uninstall <name>` to manage.
- **Arch Linux**: use **`yay`** (handles repo + AUR, calls sudo itself): `yay -Q…` to query, `yay -S` to install.
- **Hyprland** (Wayland) + **zsh**. Read compositor state with `hyprctl -j …` (`dispatch`/`reload` mutate).
- Prefer built-in **Read/Grep/Glob** over shell `cat`/`grep`/`ls`: structured results, no wasted context.
- Agent shells are minimal by design: `~/.zshrc` returns early on `$CLAUDECODE`, so no Oh My Zsh and no eza/bat/rg aliases, just plain coreutils, and `rg`/`fd`/`bat`/`jq`/`node`/`uv` are on PATH under their real names. Env, PATH and the shared helpers (`awslogin`, `winnifred`, `clip`) come from `~/.zshenv`.

## Working style

- **Never use the em dash (`—`).** Not in prose, commit messages, comments, or docs. Use a comma, parenthesis, colon, or a reworded sentence as the sense requires. When you edit a file for another reason and pass an existing em dash, replace it too.
- **Match effort to the task.** For one-off or infrequent operational work, take the simplest direct end-to-end path. Do not build wrappers, abstraction layers, custom verifiers, or automation unless the direct path hits a concrete blocker or a repeated need that justifies it.
- **Prefer quality over development cost.** Weigh approaches by simplicity, robustness, and long-term maintainability, not by what is fastest to type now.
- **Reproduce before fixing.** Start a bug fix by reproducing the failure the way a user would hit it, so the fix targets the real cause.
- **Do not step around breakage.** A lint error, failing test, or flaky test you did not cause still gets fixed or flagged, not silently ignored.
- **Do not hand-edit generated files** such as CHANGELOG.md, tool-regenerated lockfiles, or anything marked auto-generated.
- **Ask before swarming.** Before dynamic workflows, ultracode, or anything that spawns a large batch of subagents, explain the trade-offs and cost and wait for explicit approval.

## Boot setup (dual-boot Arch + Windows, UEFI)

**Do not touch GRUB.** `/etc/default/grub` and `/boot/grub/grub.cfg` exist and
`\EFI\GRUB\grubx64.efi` is still an EFI entry (`Boot0000`), but GRUB is **not**
what boots this machine. Editing it changes nothing.

- **Bootloader: systemd-boot** (`Boot0001` "Linux Boot Manager",
  `\EFI\systemd\systemd-bootx64.efi`). ESP is mounted at **`/efi`** (not `/boot/efi`).
- **Arch boots as a UKI**: `/efi/EFI/Linux/arch-linux.efi`, a single signed
  unified kernel image. The previous build is kept as `arch-linux.efi.bak` and is
  also signed, so it stays bootable as a fallback entry.
- **Kernel cmdline lives in `/etc/kernel/cmdline`**, *not* in any GRUB file. It is
  baked into the UKI's `.cmdline` section at build time.
- **To change kernel parameters**: edit `/etc/kernel/cmdline`, then rebuild with
  `sudo mkinitcpio -P` (preset: `/etc/mkinitcpio.d/linux.preset`, `default_uki=`).
  A reboot is required.
- **Secure Boot is enabled** with user-enrolled keys managed by **`sbctl`**.
  A mkinitcpio **post hook** (`/usr/lib/initcpio/post/sbctl`, not `/etc/initcpio/post/`)
  signs the UKI automatically on every rebuild. Note the UKI is *not* in
  `sbctl list-files`, so the pacman hook alone would not cover it; the mkinitcpio
  post hook is what does. Confirm with `sudo sbctl verify` before rebooting.
- **Windows** is `Boot0002` on its own ESP partition; nothing Arch-side touches it.

Verify what actually booted with `sudo bootctl list` / `sudo efibootmgr -v`, and
compare `/proc/cmdline` against `/etc/kernel/cmdline`: if a parameter is in
`/proc/cmdline` but absent from the GRUB config, that is the tell that GRUB is unused.

## Maintaining this file

Keep this to knowledge useful to almost every session on this machine. Do not
repeat what the code or `--help` already shows; point to the authoritative file
or command instead. Prefer rewriting or pruning entries over appending new ones.
Keep entries concise.
