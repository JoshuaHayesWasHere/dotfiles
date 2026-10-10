#!/usr/bin/env bash
# Checks each AWS sign-in session in ~/.aws/config with one real call and
# records which ones need a new sign-in. The status line and the aws-signin
# mod read the record; neither makes a network call of its own.
#
# The token cache's expiresAt cannot answer this: a session past it is still
# good while its refresh token works, so only a call can tell.
#
# Usage: aws-signin-check.sh [--if-older-than <seconds>]
# Record: ~/.cache/claude-statusline/aws.json
#   { "checked_at": <epoch>, "sessions": { "<name>": "ok" | "expired" | "unknown" } }
set -u

STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude-statusline"
STATE="$STATE_DIR/aws.json"
CONFIG="${AWS_CONFIG_FILE:-$HOME/.aws/config}"

max_age=0
if [ "${1:-}" = "--if-older-than" ]; then
  max_age="${2:-900}"
fi

mkdir -p "$STATE_DIR"
if [ "$max_age" -gt 0 ] && [ -e "$STATE" ]; then
  age=$(( $(date +%s) - $(stat -c %Y "$STATE") ))
  [ "$age" -lt "$max_age" ] && exit 0
fi
command -v aws >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0
[ -r "$CONFIG" ] || exit 0

# One checker at a time, and the record's age moves first so that the many
# sessions polling it do not each start one.
exec 9>"$STATE_DIR/aws.lock"
flock -n 9 || exit 0
[ -e "$STATE" ] && touch "$STATE"

# "<session> <first profile that uses it>" per line.
pairs=$(awk '
  /^\[profile / { profile = $2; sub(/\]$/, "", profile) }
  /^\[sso-session / { profile = "" }
  /^sso_session[ \t]*=/ {
    name = $0; sub(/^[^=]*=[ \t]*/, "", name); sub(/[ \t]+$/, "", name)
    if (profile != "" && !(name in seen)) { seen[name] = 1; print name, profile }
  }
' "$CONFIG")

sessions='{}'
while read -r name profile; do
  [ -n "$name" ] || continue
  if err=$(timeout 25 aws sts get-caller-identity --profile "$profile" --output text 2>&1 >/dev/null); then
    verdict=ok
  elif printf '%s' "$err" | grep -qiE 'ForbiddenException|No access'; then
    # The sign-in answered; this profile's role is simply not granted.
    verdict=ok
  elif printf '%s' "$err" | grep -qiE 'token has expired|refresh failed|sso login|session .* (expired|invalid)'; then
    verdict=expired
  else
    # No network, a timeout, or anything else that is not the sign-in itself.
    verdict=unknown
  fi
  sessions=$(jq -c --arg n "$name" --arg v "$verdict" '. + {($n): $v}' <<<"$sessions")
done <<<"$pairs"

tmp=$(mktemp "$STATE_DIR/aws.XXXXXX")
jq -n --argjson s "$sessions" --argjson t "$(date +%s)" '{checked_at: $t, sessions: $s}' >"$tmp" && mv "$tmp" "$STATE"
