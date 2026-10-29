# dotfiles

My Arch Linux and Hyprland setup: the desktop, the shell, the editor, and the
way I run Claude Code. It is a working machine's config, written by hand and
published so it can be read and borrowed from.

![The desktop: a terminal and an editor, tiled](docs/screenshots/desktop.png)

| Workspace overview (`Super+A`) | Keybind cheat sheet (`Super+Shift+K`) | Power menu |
|---|---|---|
| ![Ten workspaces as a grid of live miniatures](docs/screenshots/overview.png) | ![A searchable list of every keybind](docs/screenshots/keybinds.png) | ![Lock, log out, suspend, restart, shut down](docs/screenshots/powermenu.png) |

The screenshots are taken on an off-screen copy of the desktop; [docs/screenshots](docs/screenshots/README.md) explains how.

## What is worth a look

- **Every piece written by hand.** The launcher, notification centre, power
  menu, terminal theme and workspace overview are all original and share one
  palette, so the desktop reads as one design. The overview is a single QML
  file: [config/quickshell/shell.qml](config/quickshell/shell.qml).
- **Hyprland configured in Lua.** No generated config and no
  wallpaper-driven recolouring: one fixed palette, per-monitor workspace logic
  inside the compositor instead of in shell scripts, and every keybind carrying
  a description that the on-screen cheat sheet and [docs/keybinds.md](docs/keybinds.md)
  are both built from. Start at [config/hypr/README.md](config/hypr/README.md).
- **A shell that is fast for agents and comfortable for people.** zsh is split
  three ways so automation gets a 1 ms shell with plain coreutils while
  interactive sessions keep the full setup. [docs/shell.md](docs/shell.md)
  explains the split and lists the aliases.
- **Claude Code as part of the machine.** A status line, permission rules,
  hooks, and an [AGENTS.md](AGENTS.md) that tells agents which decisions here
  are deliberate. See [claude/](claude/).
- **Local push-to-talk dictation** on `Super+V`. The binds live here; the
  speech pipeline is its own project.
- **Checked on every push.** Shell scripts are linted, the shell helpers and the
  installer have tests, the history is scanned for secrets, and Hyprland itself
  validates the config. See [.github/workflows/check.yml](.github/workflows/check.yml).

## Layout

```
bash/        bashrc, bash_profile
claude/      Claude Code status line, example settings, global CLAUDE.md
config/      ~/.config subtrees (Hyprland, waybar, kitty, nvim, etc.), plus sddm/Xsetup
docs/        keybinds, shell, machine setup
git/         gitconfig, global ignore
gtk/         gtkrc-2.0 (GTK2; GTK3/4 live under config/)
keyd/        keyd remap config (symlinked to /etc/keyd/)
shell/       dircolors
starship/    starship.toml (prompt)
systemd/     user timers (hub-watch, docker-prune) and the hub-watch script
tests/       tests for the installer
tmux/        tmux.conf (crew session for firstmate, Catppuccin Frappe to match kitty)
zsh/         zshenv (env + PATH), zshrc (interactive only), functions.zsh (portable helpers)
```

## Setup

On a fresh [archinstall](https://wiki.archlinux.org/title/Archinstall) system
(systemd-boot with a unified kernel image), one command installs the packages,
links everything, and enables the services:

```bash
curl -fsSL https://raw.githubusercontent.com/JoshuaHayesWasHere/dotfiles/arch/bootstrap | bash
```

It is safe to re-run, and it prints the few interactive steps (GitHub and
Claude Code sign-in, a wallpaper) at the end. On a machine that already has the
packages, only link:

```bash
git clone -b arch https://github.com/JoshuaHayesWasHere/dotfiles.git ~/dotfiles
~/dotfiles/install            # everything under $HOME; --dry-run reports drift
~/dotfiles/install --system   # also /etc: keyd and the SDDM greeter layout
```

The live Claude Code settings start as a copy of `claude/settings.example.json`
and stay untracked.

## More

| Page | Covers |
|------|--------|
| [docs/keybinds.md](docs/keybinds.md) | Every keybind, generated from the running compositor |
| [config/hypr/README.md](config/hypr/README.md) | How the Hyprland config is organised, and how to test a change |
| [docs/shell.md](docs/shell.md) | The zsh split, aliases and helper commands |
| [docs/machine.md](docs/machine.md) | What `bootstrap` sets up and why: packages, keyboard remap, login screen, health timers, git and SSH |

## License

[MIT](LICENSE). The colours throughout are the
[Catppuccin](https://github.com/catppuccin/catppuccin) palette, and
`config/Kvantum/catppuccin-mocha-blue` and `config/btop/themes` are that
project's own themes, unmodified, under [its MIT license](licenses/catppuccin.txt).
