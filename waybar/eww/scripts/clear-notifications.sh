#!/bin/bash
# Clear button of the notifications panel: play the clear animation, then empty
# dunst's history. The timings follow eww.scss (.notif transitions, 45ms stagger).

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EWW=(eww --config "$DIR")

count=$("${EWW[@]}" get notifs 2>/dev/null | python3 -c 'import json,sys; print(len(json.load(sys.stdin)))' 2>/dev/null)
count=${count:-0}

# 1. entries slide out one after another: the last one starts after (count-1)*45ms
#    and takes 280ms
"${EWW[@]}" update notifs_clearing=true
sleep "$(python3 -c "print((max($count, 1) - 1) * 0.045 + 0.30)")"

# 2. the now invisible list folds up
"${EWW[@]}" update notifs_folded=true
sleep 0.24

# 3. actually clear, and reset for the next time
dunstctl history-clear
"${EWW[@]}" update notifs='[]' notifs_clearing=false notifs_folded=false
