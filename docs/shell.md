# Shell

How zsh is laid out, and the commands it adds.

## How the zsh files split

Three files, loaded in different circumstances. This split is deliberate:

| File | Loads for | Holds |
|------|-----------|-------|
| `zsh/zshenv` | **every** zsh: login, scripts, agent/automation shells | `GOPATH`, `TF_PLUGIN_CACHE_DIR`, `NVM_DIR`, `HISTFILE`, `PATH`, then sources `functions.zsh` |
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

## Aliases and helpers

### Modern CLI replacements

Interactive shells only. See [How the zsh files split](#how-the-zsh-files-split) above.
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
| `winnifred` | `uv run ~/repos/Winnifred/scripts/run-local.py` (function, args pass through) |
| `aa` | `uv run --project ~/repos/archaholics-anonymous aa`, an alias until the tool has earned a spot on `PATH`; graduating means `uv tool install --editable` (shim into `~/.local/bin`) and dropping the alias |
| `hydra-lab` | `uv run --project ~/repos/hydra-lab hydra-lab`, same alias-until-graduated pattern as `aa` |
| `pmeter` | `uv run --project ~/repos/pipeline pmeter`, same pattern; the Claude Code `Stop` hooks call it too |
| `lavish-axi-update` | Pull and rebuild the npm-linked `~/repos/lavish-axi` checkout, which nothing else updates |
| `fm` | Attach to the `firstmate` tmux session, creating it first if it is not up (function in `functions.zsh`) |
| `cl` | `claude` (launch Claude Code) |
| `claude` | Shell function, not the bare binary: launched from a bare `$HOME` it runs the session in `~/desk` (a persistently-trusted workspace, since `$HOME` itself cannot hold trust). Anywhere else it behaves exactly like `claude`. |

### System (dual-boot)

Defined in `zshrc`, not `functions.zsh`, on purpose: both need a TTY to prompt,
and agent shells have no business holding a one-word reboot command.

| Command | Description |
|---------|-------------|
| `windows` | Reboot into Windows **once**. Sets a UEFI one-shot entry the firmware consumes and clears itself, so `BootOrder` is never touched. Looks the entry up by name, because Windows updates and NVRAM resets renumber `BootXXXX`. |
| `bios` | Reboot straight into BIOS setup, bypassing Fast Boot's ~1s keyboard window. |

Both run `sudo -k` first to drop any cached credential, so a recent unrelated
`sudo` can never let a stray keystroke reboot the machine; the confirmation is
folded into that password prompt.

### AWS (SSO)

Which organizations and profiles exist is kept out of this repo. `awslogin`
reads them from `~/.config/aws-orgs.zsh`, an untracked file that fills two maps
(the comment above `awslogin` in `zsh/functions.zsh` shows the format) and
holds any per-organization shortcuts.

| Command | Description |
|---------|-------------|
| `awslogin <org>` | Sign in to that organization (device code flow), then list its accounts |
| `awslogin` | List the accounts of every organization without signing in |
| `awslogin <profile>` | Sign in through any other profile and export it |
| `awswho`     | Show current caller identity |
| `awslogout`  | Log out of SSO and unset `AWS_PROFILE` |
