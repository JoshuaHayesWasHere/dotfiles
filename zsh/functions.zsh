# ~/dotfiles/zsh/functions.zsh - portable shell helpers.
#
# Sourced from ~/.zshenv, so these are available in EVERY shell: interactive,
# scripts, and agent/Claude sessions (which skip the rest of ~/.zshrc). Keep
# this file free of anything that needs Oh My Zsh, a prompt, or a TTY.

# ── Wayland clipboard ────────────────────────────────────────────────
clip() { wl-copy "$@"; }
# Run a command, print "$ cmd" + its output, copy both to the primary selection
dclip() { { print -- "\$ ${(q-)@}"; "$@" 2>&1 } | tee >(wl-copy --primary); return ${pipestatus[1]} }

# ── AWS SSO sign-in, one per organization ────────────────────────────
# Print one line per profile: profile, account id, signed-in user. Succeeds
# when at least one profile answers, which is what "session is live" means.
_awsstatus() {
    local profile id live=1
    for profile in "$@"; do
        if id=$(aws sts get-caller-identity --profile "$profile" \
                --query '[Account,Arn]' --output text 2>/dev/null); then
            printf '%-20s %s  %s\n' "$profile" "${id%%[[:space:]]*}" "${id##*/}"
            live=0
        else
            printf '%-20s no access\n' "$profile"
        fi
    done
    return $live
}

# Which organizations exist is private to a machine, so they are not listed
# here. ~/.config/aws-orgs.zsh, which is not tracked, fills these two maps:
#   AWS_ORG_PROFILES[acme]="acme-dev acme-prod"   the profiles to list
#   AWS_ORG_LOGIN[acme]="--sso-session Acme"      how `aws sso login` reaches it
# It is also the place for per-organization shortcuts, such as
#   acmedev() { awslogin acme && export AWS_PROFILE=acme-dev; }
typeset -gA AWS_ORG_PROFILES AWS_ORG_LOGIN
[ -r "${AWS_ORGS_FILE:-$HOME/.config/aws-orgs.zsh}" ] && source "${AWS_ORGS_FILE:-$HOME/.config/aws-orgs.zsh}"

# awslogin <org>      sign in to that organization, then list its accounts
# awslogin            list the accounts of every organization, no sign-in
# awslogin <profile>  sign in through that profile and export AWS_PROFILE
awslogin() {
    local -A profiles=("${(@kv)AWS_ORG_PROFILES}") login=("${(@kv)AWS_ORG_LOGIN}")
    local org="$1" lines

    if [[ -z "$org" ]]; then
        for org in ${(ko)profiles}; do
            print -- "$org:"
            _awsstatus ${=profiles[$org]}
        done
        return 0
    fi

    # Anything that is not an organization is taken as a profile name.
    if [[ -z "${profiles[$org]}" ]]; then
        profiles[$org]="$org"
        login[$org]="--profile $org"
        export AWS_PROFILE="$org"
    fi

    if lines=$(_awsstatus ${=profiles[$org]}); then
        print -- "$org: session already live, skipping sign-in"
        print -- "$lines"
        return 0
    fi

    # Always the device code flow: over SSH from a phone, a browser redirect
    # back to this machine cannot complete.
    aws sso login ${=login[$org]} --use-device-code || return
    _awsstatus ${=profiles[$org]}
}

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
