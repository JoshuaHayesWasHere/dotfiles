# Global preferences

- **Python: use `uv`** (`uv run`, `uv add`, `uv sync`, `uv venv`). Never `pip install`, `python -m venv`, or `source .../activate`.
- **Local utilities are `uv` projects**, never loose `python foo.py` scripts. Throwaway one-offs may sit in `~/desk`; anything with a name and a git repo gets its own top-level `~/repos/<name>`. Run it as a zsh alias (`alias aa='uv run --project "$HOME/repos/<name>" aa'` in `~/dotfiles/zsh/zshrc`) until it has earned a spot on `PATH`. Graduating is `uv tool install --editable <path>`: the entry-point shim lands in `~/.local/bin` while the code still runs live from the source tree; drop the alias at that point.
- Arch Linux: install and query packages with `yay` (handles repo + AUR, calls sudo itself).
- Hyprland (Wayland) + zsh. Read compositor state with `hyprctl -j …` (`dispatch`/`reload` mutate).
- Agent shells are minimal by design: `~/.zshrc` returns early when `$CLAUDECODE` or `$AI_AGENT` is set, so no Oh My Zsh and no eza/bat/rg aliases, just plain coreutils, and `rg`/`fd`/`bat`/`jq`/`node`/`uv` are on PATH under their real names. Agents run bash, so write bash: Claude through `CLAUDE_CODE_SHELL` in `~/.claude/settings.json`, Codex through the `~/dotfiles/bin/codex` wrapper T3 Code launches, Cursor through `SHELL` in its T3 provider settings. The account and terminals stay on zsh. Env and PATH come from whatever started the agent (T3 Code here), and `awslogin`, `winnifred` and `clip` are commands in `~/.local/bin`, from `~/dotfiles/bin`.
- Boot setup (systemd-boot, UKIs, kernel cmdline): read `~/dotfiles/docs/machine.md` before touching anything boot-related.

## Working style

- Size effort in t-shirt sizes, not days or hours.
- Match effort to the task. For one-off or infrequent operational work, take the simplest direct end-to-end path. Do not build wrappers, abstraction layers, custom verifiers, or automation unless the direct path hits a concrete blocker or a repeated need that justifies it.
- Prefer quality over development cost. Weigh approaches by simplicity, robustness, and long-term maintainability, not by what is fastest to type now.
- **Reproduce before fixing.** Start a bug fix by reproducing the failure the way a user would hit it, so the fix targets the real cause.
- **Do not step around breakage.** A lint error, failing test, or flaky test you did not cause still gets fixed or flagged, not silently ignored.
- Do not hand-edit generated files such as CHANGELOG.md, tool-regenerated lockfiles, or anything marked auto-generated.
- Ask before swarming. Before dynamic workflows or large subagent batches, explain the trade-offs and cost and wait for explicit approval.
