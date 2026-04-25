#!/usr/bin/env bash
INPUT=$(cat)
# Debug: echo "$INPUT" > /tmp/statusline-debug.json

echo "$INPUT" | python3 -c "
import sys, json, datetime, os, subprocess, re

# ANSI colors
R      = '\033[0m'
BOLD   = '\033[1m'
GRAY   = '\033[90m'
RED    = '\033[91m'
YELLOW = '\033[93m'
GREEN  = '\033[92m'
CYAN   = '\033[96m'
WHITE  = '\033[97m'
MAG    = '\033[95m'

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

def fmt_reset(ts):
    if not ts: return ''
    try:
        t = datetime.datetime.fromtimestamp(int(ts))
        return t.strftime('%-I:%M %p')
    except: return ''

def strip_ansi(s):
    return re.sub(r'\033\[[0-9;]*[mK]', '', s)

def vlen(s):
    return len(strip_ansi(s))

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
if len(parts) > 4:
    cwd = '..' + '/' + '/'.join(parts[-2:])
dir_str = f'{CYAN}{BOLD}{cwd}{R}'

# Git branch
try:
    branch = subprocess.check_output(
        ['git', '-C', data.get('cwd') or os.getcwd(), 'branch', '--show-current'],
        stderr=subprocess.DEVNULL
    ).decode().strip()
    branch_str = f'{YELLOW}{branch}{R}' if branch else ''
except:
    branch_str = ''

# Time — H:MM AM/PM, no leading zero
now = datetime.datetime.now()
time_str = f'{WHITE}{now.strftime(\"%-I:%M %p\")}{R}'

# Context
ctx = data.get('context_window') or {}
cu  = ctx.get('used_percentage')
ctx_str = f'{GRAY}ctx:{R}{used_color(cu)}{BOLD}{fmt_pct(cu)}%{R}'

# Compaction warning (fires at 80%)
try:
    left = int(80 - float(cu))
    if left <= 0:
        compact_str = f'{RED}{BOLD}COMPACT NOW{R}'
    else:
        c = GREEN if left > 30 else (YELLOW if left > 10 else RED)
        compact_str = f'{c}{left}% til warn{R}'
except:
    compact_str = f'{GRAY}?{R}'

# 5h rate limit
rate = data.get('rate_limits') or {}
w5   = rate.get('five_hour') or {}
r5p  = w5.get('used_percentage')
r5_str = f'{GRAY}5h:{R}{used_color(r5p)}{fmt_pct(r5p)}%{R}'
rst5 = fmt_reset(w5.get('resets_at'))
if rst5:
    r5_str += f'  {GRAY}rst {rst5}{R}'

# Terminal width for right-aligning the time
try:
    term_width = os.get_terminal_size().columns
except:
    term_width = 80

sep = f'  {GRAY}|{R}  '

# Line 1: dir  |  branch  [right-aligned]  time
left_parts = [dir_str] + ([branch_str] if branch_str else [])
line1_left = sep.join(left_parts)
padding = max(2, term_width - vlen(line1_left) - vlen(time_str))
line1 = line1_left + ' ' * padding + time_str

# Line 2: ctx  |  compact warn  |  5h usage
line2 = sep.join([ctx_str, compact_str, r5_str])

print(line1)
print(line2)
" 2>/dev/null
