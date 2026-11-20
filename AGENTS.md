# dotfiles

The owner's Arch Linux and Hyprland setup: desktop, shell, editor and agent config, published so others can read it. `install` links it into `$HOME` (and `/etc` with `--system`), `bootstrap` sets up a fresh machine. `README.md` covers the pieces, `docs/machine.md` the packages, boot and services, `docs/shell.md` the zsh split, and `config/hypr/README.md` the Hyprland config.

## Commands

The checks `.github/workflows/check.yml` runs, from the repo root. The helper tests stub `aws` and the installer tests use a throwaway `$HOME`, so neither touches anything real.

```sh
shellcheck -s sh config/hypr/scripts/*
shellcheck bootstrap install tests/install.test.sh claude/statusline.sh claude/aws-signin-check.sh config/sddm/Xsetup systemd/hub-watch
for f in zsh/zshenv zsh/zshrc zsh/functions.zsh; do zsh -n "$f"; done
zsh zsh/functions.test.zsh
sh tests/install.test.sh
for f in config/hypr/*.lua; do luac -p "$f"; done
find config/nvim -name '*.lua' -print0 | xargs -0 -n1 luajit -bl > /dev/null
git ls-files '*.json' | xargs -r -n1 jq empty
gitleaks git --no-banner --log-opts=--all .
d=$(mktemp -d); XDG_RUNTIME_DIR="$d" Hyprland --verify-config -c "$PWD/config/hypr/hyprland.lua"; rm -rf "$d"  # prints "config ok"
```

| What | Command |
|---|---|
| Link drift on this machine | `cd ~/dotfiles && ./install --dry-run` (changes nothing; exits 1 when anything would change) |
| Link into `$HOME` / `/etc` | `./install` / `./install --system`, from `~/dotfiles` after a merge |
| Regenerate `docs/keybinds.md` | `config/hypr/scripts/keybinds markdown > docs/keybinds.md` |

`docs/keybinds.md` is generated from the running compositor, so after changing a bind, regenerate it once the bind is live. Never edit it by hand.

## The live machine

- `~/dotfiles` is the live config: everything is symlinked from it, and Hyprland reloads its config when a file there changes. Make changes in a worktree; they go live when merged into `arch` and pulled into `~/dotfiles`. `./install --dry-run` in a worktree compares against the worktree's own paths, so its output means nothing there.
- The main checkout often holds the owner's uncommitted work. Do not commit, stash or reset it unless asked.
- `agents/AGENTS.md` is the global instruction file every agent on the machine loads (`install` links it for Claude Code and Codex). A change there changes every repo's agents.
- Try a look change on the off-screen desktop in `docs/screenshots/README.md` before touching the real session.

## Rules

- This repo is public. Names of private repos, AWS organizations, profiles, hosts and personal email addresses stay out of it. AWS organizations live in the untracked `~/.config/aws-orgs.zsh`. The live Claude settings are an untracked file from another repo linked at `~/.claude/settings.json`; mirror any setting worth showing into `claude/settings.example.json` by hand.
- Stage files by name. `git add <dir>` has swept runtime state into a commit before.
- `zsh/zshrc` returns early for agent shells on purpose. Do not move interactive weight into `zsh/zshenv`, and do not add aliases that shadow coreutils anywhere an agent shell sources them.
- Hyprland is configured in Lua, so anything that dispatches from outside (waybar, swaync, wlogout, quickshell, scripts) sends a Lua expression, for example `hyprctl dispatch 'hl.dsp.focus({ workspace = 3 })'`. The legacy `hyprctl dispatch workspace 3` form does not parse.
- Scripts under `config/hypr/scripts` are POSIX `sh`.
- Move Nerd Font icon glyphs (waybar, swaync) with a tool, never by retyping. They are private-use characters that do not survive it.
- Every theme is written for this repo. Do not paste one in from another dotfiles project. The only third-party themes are the official Catppuccin ones for Kvantum and btop, MIT and credited in the README.

## Commits and PRs

PRs target `arch`, the default branch. Commit subjects are `area: what changed`, lowercase area, for example `hypr: Super+Alt+D toggles dictation hands-free` or `agents: one global AGENTS.md that Claude Code and Codex both read`. Areas in use: `hypr`, `nvim`, `agents`, `ci`, `chore`.

## Done means

End every task by saying: committed, pushed, merged, whether `~/dotfiles` was pulled so the change is live, whether `./install` ran, and whether anything needs a reboot or relogin. Remove worktrees and branches you created once their work has merged.
