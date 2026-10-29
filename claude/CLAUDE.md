# Global preferences

- **Python: use `uv`** (`uv run`, `uv add`, `uv sync`, `uv venv`). Never `pip install`, `python -m venv`, or `source .../activate`.
- **Local utilities: build them as `uv` projects**, never loose `python foo.py` scripts. Throwaway one-offs may sit in `~/desk`; anything with a name and a git repo gets its own top-level `~/repos/<name>`. Run it as a **zsh alias** (`alias aa='uv run --project "$HOME/repos/<name>" aa'` in `~/dotfiles/zsh/zshrc`) until it has earned a spot on `PATH`. **Graduating** is `uv tool install --editable <path>`: the entry-point shim lands in `~/.local/bin` while the code still runs live from the source tree; drop the alias at that point. `uv tool list` / `uv tool uninstall <name>` to manage.
- **Arch Linux**: use **`yay`** (handles repo + AUR, calls sudo itself): `yay -Q…` to query, `yay -S` to install.
- **Hyprland** (Wayland) + **zsh**. Read compositor state with `hyprctl -j …` (`dispatch`/`reload` mutate).
- Prefer built-in **Read/Grep/Glob** over shell `cat`/`grep`/`ls`: structured results, no wasted context.
- Agent shells are minimal by design: `~/.zshrc` returns early on `$CLAUDECODE`, so no Oh My Zsh and no eza/bat/rg aliases, just plain coreutils, and `rg`/`fd`/`bat`/`jq`/`node`/`uv` are on PATH under their real names. Env, PATH and the shared helpers (`awslogin`, `winnifred`, `clip`) come from `~/.zshenv`.

## Working style

- **Never use the em dash (`—`).** Not in prose, commit messages, comments, or docs. Use a comma, parenthesis, colon, or a reworded sentence as the sense requires. When you edit a file for another reason and pass an existing em dash, replace it too.
- **NEVER make assumptions about effort using tangible days or time, use t-shirt sizes.**
- **Match effort to the task.** For one-off or infrequent operational work, take the simplest direct end-to-end path. Do not build wrappers, abstraction layers, custom verifiers, or automation unless the direct path hits a concrete blocker or a repeated need that justifies it.
- **Prefer quality over development cost.** Weigh approaches by simplicity, robustness, and long-term maintainability, not by what is fastest to type now.
- **Reproduce before fixing.** Start a bug fix by reproducing the failure the way a user would hit it, so the fix targets the real cause.
- **Do not step around breakage.** A lint error, failing test, or flaky test you did not cause still gets fixed or flagged, not silently ignored.
- **Do not hand-edit generated files** such as CHANGELOG.md, tool-regenerated lockfiles, or anything marked auto-generated.
- **Ask before swarming.** Before dynamic workflows, ultracode, or anything that spawns a large batch of subagents, explain the trade-offs and cost and wait for explicit approval.
- **Every interactive artifact can send itself back.** Any artifact with buttons, choices, or comment fields carries a "Send to firstmate" button (outside firstmate: "Send to Claude") that sends the page's current choices and notes to the agent on demand, through the `comments` capability's `sendToClaude`. The button only works while a session watches the page with auto-replies armed, so keep that watch live for as long as the page waits on an answer, and re-arm it after a restart or context reset.

## Boot setup (UEFI, systemd-boot, no GRUB)

- **Bootloader: systemd-boot** ("Linux Boot Manager", `\EFI\systemd\systemd-bootx64.efi`).
  There is no GRUB on this machine. The ESP is mounted at **`/boot`** and is
  root-only, so reading it needs `sudo`.
- **Arch boots as a UKI**: `/boot/EFI/Linux/arch-linux.efi`, plus
  `arch-linux-lts.efi` from `linux-lts` as the fallback entry. systemd-boot finds
  UKIs there by itself; there are no loader entries to edit.
- **Kernel cmdline lives in `/etc/kernel/cmdline`**, baked into each UKI's
  `.cmdline` section at build time.
- **To change kernel parameters**: edit `/etc/kernel/cmdline`, then rebuild with
  `sudo mkinitcpio -P` (presets: `/etc/mkinitcpio.d/linux{,-lts}.preset`, `default_uki=`).
  A reboot is required.
- **Secure Boot is off.** Nothing is signed and `sbctl` is not installed.
- **Windows**, when installed, lives on its own drive with its own ESP; nothing
  Arch-side touches it. The zsh `windows` helper picks the first
  "Windows Boot Manager" entry in `efibootmgr`.

Verify what actually booted with `sudo bootctl list` / `sudo efibootmgr -v`, and
compare `/proc/cmdline` against `/etc/kernel/cmdline`.

## Maintaining this file

Keep this to knowledge useful to almost every session on this machine. Do not
repeat what the code or `--help` already shows; point to the authoritative file
or command instead. Prefer rewriting or pruning entries over appending new ones.
Keep entries concise.
