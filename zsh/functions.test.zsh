#!/usr/bin/env zsh
# Checks awslogin against a stub `aws`, so no real sign-in ever runs.
# Usage: zsh zsh/functions.test.zsh

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export STUB="$tmp"

# The stub answers sts only while $STUB/live exists, never for globex-bots, and
# records every `sso login` in $STUB/log (which also makes the session live).
cat > "$tmp/aws" <<'STUBEOF'
#!/bin/sh
case "$1 $2" in
"sso login")
    echo "$*" >> "$STUB/log"
    [ -e "$STUB/fail" ] && exit 1
    : > "$STUB/live" ;;
"sts get-caller-identity")
    [ -e "$STUB/live" ] || exit 255
    [ "$4" = globex-bots ] && exit 255
    printf '111122223333\tarn:aws:sts::111122223333:assumed-role/Admin/tester\n' ;;
*) exit 2 ;;
esac
STUBEOF
chmod +x "$tmp/aws"
path=("$tmp" $path)

# Two made-up organizations stand in for the untracked ~/.config/aws-orgs.zsh.
cat > "$tmp/orgs.zsh" <<'ORGSEOF'
AWS_ORG_PROFILES=(
    acme   "acme-mgmt acme-dev acme-prod"
    globex "globex-admin globex-dev globex-dev-admin globex-prod-bootstrap globex-bots"
)
AWS_ORG_LOGIN=(
    acme   "--profile acme-prod"
    globex "--sso-session Globex"
)
acmedev() { awslogin acme && export AWS_PROFILE=sandbox; }
ORGSEOF
export AWS_ORGS_FILE="$tmp/orgs.zsh"

source "${0:A:h}/functions.zsh"

fails=0
check() {  # check <description> <actual> <expected>
    if [[ "$2" == "$3" ]]; then
        print "ok   $1"
    else
        print "FAIL $1\n  expected: ${(q+)3}\n  actual:   ${(q+)2}"
        (( fails++ ))
    fi
}
reset() { rm -f "$tmp"/{live,log,fail}; unset AWS_PROFILE; }
logged() { [[ -e "$tmp/log" ]] && <"$tmp/log"; }
row() { printf '%-20s %s' "$1" "${2:-111122223333  tester}"; }

reset
out=$(awslogin acme)
check "acme signs in with the device code flow" "$(logged)" \
    "sso login --profile acme-prod --use-device-code"
check "acme lists its profiles" "$out" \
    "$(row acme-mgmt)"$'\n'"$(row acme-dev)"$'\n'"$(row acme-prod)"

: > "$tmp/log"
out=$(awslogin acme)
check "live session skips the sign-in" "$(logged)" ""
check "live session says so" "${out%%$'\n'*}" "acme: session already live, skipping sign-in"

reset
out=$(awslogin globex)
check "globex signs in by sso-session" "$(logged)" \
    "sso login --sso-session Globex --use-device-code"
check "unreachable profile reads no access" "${out##*$'\n'}" "$(row globex-bots 'no access')"
check "globex lists five profiles" "${#${(f)out}}" 5

out=$(awslogin)
check "no argument lists every organization" "${#${(f)out}}" 10
check "no argument does not sign in" "$(logged)" \
    "sso login --sso-session Globex --use-device-code"

reset
awslogin acme >/dev/null
check "organization sign-in leaves AWS_PROFILE alone" "${AWS_PROFILE-unset}" unset

reset
acmedev >/dev/null
check "a shortcut from the orgs file signs in" "$(logged)" "sso login --profile acme-prod --use-device-code"
check "a shortcut from the orgs file sets its profile" "$AWS_PROFILE" sandbox

reset
out=$(awslogin custom)
awslogin custom >/dev/null
check "unknown argument signs in as a profile" "$(logged)" "sso login --profile custom --use-device-code"
check "unknown argument prints one identity" "${out##*$'\n'}" "$(row custom)"
check "unknown argument exports the profile" "$AWS_PROFILE" custom

reset
: > "$tmp/fail"
awslogin globex >/dev/null
check "failed sign-in returns nonzero" "$?" 1

(( fails == 0 )) || { print "$fails failed"; exit 1; }
print "all passed"
