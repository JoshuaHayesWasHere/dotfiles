#!/usr/bin/env bash
INPUT=$(cat)
# Debug: echo "$INPUT" > /tmp/statusline-debug.json

echo "$INPUT" | python3 -c "
import sys, json, datetime, os

# ANSI colors
R      = '\033[0m'
BOLD   = '\033[1m'
DIM    = '\033[2m'
GRAY   = '\033[90m'
RED    = '\033[91m'
YELLOW = '\033[93m'
GREEN  = '\033[92m'
CYAN   = '\033[96m'
WHITE  = '\033[97m'
BLUE   = '\033[94m'
MAG    = '\033[95m'

def used_color(pct):
    try: v = float(pct)
    except: return GRAY
    if v < 50: return GREEN
    if v < 80: return YELLOW
    return RED

try:
    data = json.load(sys.stdin)
except:
    data = {}

# Model
m = data.get('model') or {}
model = (m.get('display_name') or m.get('id') or 'unknown') if isinstance(m, dict) else str(m)

# Directory (from JSON cwd, fall back to shell cwd)
cwd = data.get('cwd') or os.getcwd()
home = os.path.expanduser('~')
if cwd.startswith(home):
    cwd = '~' + cwd[len(home):]
parts = cwd.split('/')
if len(parts) > 4:
    cwd = '..' + '/' + '/'.join(parts[-2:])

# Context
ctx      = data.get('context_window') or {}
ctx_used = ctx.get('used_percentage')
ctx_rem  = ctx.get('remaining_percentage')

# Cost
cost_usd = (data.get('cost') or {}).get('total_cost_usd')

# Rate limits
rate = data.get('rate_limits') or {}
w5   = rate.get('five_hour') or {}
w7   = rate.get('seven_day') or {}

def fmt_pct(v):
    if v is None: return '?'
    try: return str(round(float(v)))
    except: return '?'

def fmt_reset(ts):
    if not ts: return ''
    try:
        return datetime.datetime.fromtimestamp(int(ts)).strftime('%I:%M %p')
    except: return ''

def fmt_cost(v):
    if v is None: return '?'
    try: return f'\${float(v):.2f}'
    except: return '?'

sep = f'  {GRAY}|{R}  '

# Directory
dir_str = f'{CYAN}{BOLD}{cwd}{R}'

# Model
model_str = f'{MAG}{model}{R}'

# Context used
cu = ctx_used
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

# Time
now = datetime.datetime.now().strftime('%I:%M:%S %p')
time_str = f'{WHITE}{now}{R}'

# Rate limits
r5p = w5.get('used_percentage')
r7p = w7.get('used_percentage')
if r5p is not None or r7p is not None:
    r5 = f'{GRAY}5h:{R}{used_color(r5p)}{fmt_pct(r5p)}%{R}'
    rst5 = fmt_reset(w5.get('resets_at'))
    if rst5: r5 += f'{GRAY} rst {rst5}{R}'

    r7 = f'{GRAY}7d:{R}{used_color(r7p)}{fmt_pct(r7p)}%{R}'
    rst7 = fmt_reset(w7.get('resets_at'))
    if rst7: r7 += f'{GRAY} rst {rst7}{R}'

    rl_str = r5 + '  ' + r7
else:
    rl_str = f'{GRAY}usage:N/A{R}'

# Cost
cost_str = f'{GRAY}cost:{R}{YELLOW}{fmt_cost(cost_usd)}{R}'

print(sep.join([dir_str, model_str, ctx_str, compact_str, time_str, rl_str, cost_str]))
" 2>/dev/null
