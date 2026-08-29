# Global preferences

- **Python: use `uv`** (`uv run`, `uv add`, `uv sync`, `uv venv`). Never `pip install`, `python -m venv`, or `source .../activate`.
- **Arch Linux**: use **`yay`** (handles repo + AUR, calls sudo itself) — `yay -Q…` to query, `yay -S` to install.
- **Hyprland** (Wayland) + **zsh**. Read compositor state with `hyprctl -j …` (`dispatch`/`reload` mutate).
- Prefer built-in **Read/Grep/Glob** over shell `cat`/`grep`/`ls` — structured results, no wasted context.
- Agent shells are minimal by design: `~/.zshrc` returns early on `$CLAUDECODE`, so no Oh My Zsh and no eza/bat/rg aliases — plain coreutils, and `rg`/`fd`/`bat`/`jq`/`node`/`uv` are on PATH under their real names. Env, PATH and the shared helpers (`awslogin`, `winnifred`, `clip`) come from `~/.zshenv`.
