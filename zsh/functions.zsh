# ~/dotfiles/zsh/functions.zsh - portable shell helpers.
#
# Sourced from ~/.zshenv, so these are available in EVERY shell: interactive,
# scripts, and agent/Claude sessions (which skip the rest of ~/.zshrc). Keep
# this file free of anything that needs Oh My Zsh, a prompt, or a TTY.

# ── Wayland clipboard ────────────────────────────────────────────────
clip() { wl-copy "$@"; }
# Run a command, print "$ cmd" + its output, copy both to the primary selection
dclip() { { print -- "\$ ${(q-)@}"; "$@" 2>&1 } | tee >(wl-copy --primary); return ${pipestatus[1]} }

# ── AWS SSO profile switchers ────────────────────────────────────────
awslogin() {
    local profile="$1"
    export AWS_PROFILE="$profile"

    if aws sts get-caller-identity --profile "$profile" >/dev/null 2>&1; then
        aws sts get-caller-identity --profile "$profile"
        return 0
    fi

    if aws sso login --profile "$profile"; then
        aws sts get-caller-identity --profile "$profile"
        return 0
    fi

    aws sso login --profile "$profile" --use-device-code
    aws sts get-caller-identity --profile "$profile"
}

awsdev()      { awslogin sandbox; }
awsadmin()    { awslogin admin; }
awslrpdev()   { awslogin lrp-sandbox; }
awslrpadmin() { awslogin lrp-admin; }

awswho()   { aws sts get-caller-identity --profile "${AWS_PROFILE:-default}"; }
awslogout() { aws sso logout >/dev/null 2>&1; unset AWS_PROFILE; }

# ── Project shortcuts ───────────────────────────────────────────────
winnifred() { uv run ~/repos/Winnifred/scripts/run-local.py "$@"; }

# ── firstmate crew session ───────────────────────────────────────────
# Attach to the tmux session the firstmate crew lives in, creating it with the
# first mate at the helm if it is not up yet. Crew workers appear as sibling
# fm-<task-id> windows, so prefix + w is the whole fleet. Safe from inside tmux.
fm() {
  local session=firstmate win
  if ! tmux has-session -t "$session" 2>/dev/null; then
    win=$(tmux new-session -d -s "$session" -n helm -c "$HOME/repos/firstmate" -P -F '#{window_id}') || return 1
    tmux send-keys -t "$win" 'claude' C-m
  fi
  if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "$session"
  else
    tmux attach -t "$session"
  fi
}
