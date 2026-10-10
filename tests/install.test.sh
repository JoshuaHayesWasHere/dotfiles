#!/bin/sh
# Runs ./install against a throwaway $HOME, so nothing real is linked.
# Usage: sh tests/install.test.sh
set -u

repo=$(cd "$(dirname "$0")/.." && pwd -P)
home=$(mktemp -d)
trap 'rm -rf "$home"' EXIT
export HOME="$home"
unset XDG_CONFIG_HOME

fails=0
check() { # check <description> <command...>
    desc=$1; shift
    if "$@" >/dev/null 2>&1; then echo "ok   $desc"; else echo "FAIL $desc"; fails=$((fails + 1)); fi
}
points_at() { [ "$(readlink -f "$1")" = "$(readlink -f "$repo/$2")" ]; }
not() { ! "$@"; }

# The real settings.json is private and untracked; if the checkout has one,
# leave it alone and only test the copy step when it is absent.
had_settings=0; [ -e "$repo/claude/settings.json" ] && had_settings=1

check "a dry run on an empty home reports work and exits 1" not "$repo/install" --dry-run
check "a dry run links nothing" not test -e "$HOME/.zshenv"

check "install succeeds on an empty home" "$repo/install"
check "a file is linked" points_at "$HOME/.zshenv" zsh/zshenv
check "a config directory is linked" points_at "$HOME/.config/hypr" config/hypr
check "a systemd unit is linked" points_at "$HOME/.config/systemd/user/hub-watch.timer" systemd/user/hub-watch.timer
check "sddm is not linked under ~/.config" not test -e "$HOME/.config/sddm"
check "the Claude settings are linked" points_at "$HOME/.claude/settings.json" claude/settings.json
check "a second run changes nothing and exits 0" "$repo/install" --dry-run

rm "$HOME/.zshrc"; echo mine > "$HOME/.zshrc"
check "a file that is not ours is a conflict" not "$repo/install"
check "the conflicting file is left alone" grep -q mine "$HOME/.zshrc"
check "--force moves it aside and links" "$repo/install" --force
check "the link is in place after --force" points_at "$HOME/.zshrc" zsh/zshrc
backed_up() { grep -q mine "$HOME"/.zshrc.bak.*; }
check "the original survives as a backup" backed_up

[ "$had_settings" -eq 1 ] || rm -f "$repo/claude/settings.json"

[ "$fails" -eq 0 ] || { echo "$fails failed"; exit 1; }
echo "all passed"
