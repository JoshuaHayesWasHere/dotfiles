#!/usr/bin/env bash
INPUT=$(cat)
# Debug: echo "$INPUT" > /tmp/statusline-debug.json

echo "$INPUT" | python3 -c "
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
        return datetime.datetime.fromtimestamp(int(ts)).strftime('%-I:%M %p')
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
if len(parts) > 4:
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

time_str = f'{WHITE}{datetime.datetime.now().strftime(\"%-I:%M %p\")}{R}'
sep  = f'  {GRAY}|{R}  '
pipe = f'  {GRAY}|{R}  '

# git seg: branch  ●N ↑N ↓N  |  time
git_seg_parts = []
if branch: git_seg_parts.append(f'{YELLOW}{branch}{R}')
if git_status_parts: git_seg_parts.append(' '.join(git_status_parts))
git_seg = '  '.join(git_seg_parts) + pipe + time_str

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

# Line 1: dir  |  branch  ●N ↑N ↓N  |  time
line1 = sep.join([dir_str, git_seg])

# Line 2: ctx  |  compact warn  |  5h usage
line2 = sep.join([ctx_str, compact_str, r5_str])

print(line1)
print(line2)
" 2>/dev/null
