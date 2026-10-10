#!/usr/bin/env bash
INPUT=$(cat)

HERE=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
AWS_STATE="${XDG_CACHE_HOME:-$HOME/.cache}/claude-statusline/aws.json"

# The sign-in check makes a real call, so it runs detached and at most once
# every 15 minutes across every session; this script only reads its record.
( setsid bash "$HERE/aws-signin-check.sh" --if-older-than 900 >/dev/null 2>&1 & ) 2>/dev/null

# The width of the pane this session draws in: the script has no terminal of
# its own, so tmux is asked first.
WIDTH=""
if [ -n "${TMUX_PANE:-}" ]; then
  WIDTH=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_width}' 2>/dev/null)
fi
if [ -z "$WIDTH" ]; then
  WIDTH=$( (stty size </dev/tty) 2>/dev/null | cut -d' ' -f2)
fi

echo "$INPUT" | STATUS_WIDTH="${WIDTH:-120}" AWS_STATE="$AWS_STATE" python3 -c "
import sys, json, datetime, os, subprocess

# ANSI colors
R      = '\033[0m'
BOLD   = '\033[1m'
GRAY   = '\033[90m'
RED    = '\033[91m'
YELLOW = '\033[93m'
GREEN  = '\033[92m'
CYAN   = '\033[96m'
WHITE  = '\033[97m'

try: width = int(os.environ.get('STATUS_WIDTH') or 120)
except: width = 120
narrow = width < 70

def used_color(pct):
    try: v = float(pct)
    except: return GRAY
    if v < 50: return GREEN
    if v < 80: return YELLOW
    return RED

def fmt_pct(v):
    if v is None: return '?'
    try: return str(round(float(v)))
    except: return '?'

def fmt_reset(ts, fmt):
    if not ts: return ''
    try:
        return datetime.datetime.fromtimestamp(int(ts)).strftime(fmt)
    except: return ''

try:
    data = json.load(sys.stdin)
except:
    data = {}

# Directory
cwd = data.get('cwd') or os.getcwd()
home = os.path.expanduser('~')
if cwd.startswith(home):
    cwd = '~' + cwd[len(home):]
parts = cwd.split('/')
if narrow:
    cwd = parts[-1] or cwd
elif len(parts) > 4:
    cwd = '..' + '/' + '/'.join(parts[-2:])
dir_str = f'{CYAN}{BOLD}{cwd}{R}'

# Git info
git_cwd = data.get('cwd') or os.getcwd()

def run_git(args):
    try:
        return subprocess.check_output(
            ['git', '-C', git_cwd] + args,
            stderr=subprocess.DEVNULL
        ).decode().strip()
    except:
        return ''

branch = run_git(['branch', '--show-current'])
dirty  = len([l for l in run_git(['status', '--porcelain']).splitlines() if l.strip()])
try: ahead  = int(run_git(['rev-list', '@{u}..HEAD', '--count']) or 0)
except: ahead = 0
try: behind = int(run_git(['rev-list', 'HEAD..@{u}', '--count']) or 0)
except: behind = 0

git_status_parts = []
if dirty:  git_status_parts.append(f'{YELLOW}●{dirty}{R}')
if ahead:  git_status_parts.append(f'{CYAN}↑{ahead}{R}')
if behind: git_status_parts.append(f'{RED}↓{behind}{R}')

sep = f' {GRAY}|{R} ' if narrow else f'  {GRAY}|{R}  '

# Model
model = data.get('model') or {}
model_name = model.get('display_name') or model.get('id') or ''
model_str = f'{GREEN}{BOLD}{model_name}{R}' if model_name else ''

# Line 1: dir | branch ●N ↑N ↓N | model | time (the time is dropped when narrow)
if branch and narrow and len(branch) > 22:
    branch = branch[:21] + '…'
branch_str = f'{YELLOW}{branch}{R}' if branch else f'{GRAY}none{R}'
if git_status_parts:
    branch_str += ('  ' if not narrow else ' ') + ' '.join(git_status_parts)
line1_parts = [dir_str, branch_str]
if model_str:
    line1_parts.append(model_str)
if not narrow:
    line1_parts.append(f'{WHITE}{datetime.datetime.now().strftime(\"%-I:%M %p\")}{R}')

# Context: the figure, and a loud note only once compaction is due (80%)
ctx = data.get('context_window') or {}
cu  = ctx.get('used_percentage')
ctx_str = f'{GRAY}ctx:{R}{used_color(cu)}{BOLD}{fmt_pct(cu)}%{R}'
try:
    if float(cu) >= 80:
        ctx_str += f' {RED}{BOLD}COMPACT NOW{R}'
except: pass

# Plan limits: five hours and seven days
rate = data.get('rate_limits') or {}

def limit(key, label, reset_fmt):
    w = rate.get(key) or {}
    p = w.get('used_percentage')
    if p is None and not w:
        return ''
    s = f'{GRAY}{label}:{R}{used_color(p)}{fmt_pct(p)}%{R}'
    rst = '' if narrow else fmt_reset(w.get('resets_at'), reset_fmt)
    if rst:
        s += f' {GRAY}rst {rst}{R}'
    return s

line2_parts = [ctx_str]
for seg in (limit('five_hour', '5h', '%-I:%M %p'), limit('seven_day', '7d', '%a %-I %p')):
    if seg:
        line2_parts.append(seg)

# AWS sign-ins: nothing while they work, red once one needs a new sign-in
try:
    with open(os.environ.get('AWS_STATE') or '') as f:
        sessions = (json.load(f).get('sessions') or {})
    expired = sorted(name for name, verdict in sessions.items() if verdict == 'expired')
    if expired:
        # A long CamelCase session name is shown by its capitals.
        def short(n):
            caps = ''.join(c for c in n if c.isupper())
            return caps if len(n) > 12 and len(caps) > 1 else n
        names = ', '.join(short(n) for n in expired)
        line2_parts.append(f'{RED}{BOLD}AWS: {names} expired{R}')
except: pass

print(sep.join(line1_parts))
print(sep.join(line2_parts))
" 2>/dev/null
