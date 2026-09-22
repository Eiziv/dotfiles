#!/usr/bin/env python3
"""Streams PipeWire/PulseAudio state as one JSON line per change (Eww `deflisten`)."""
import json
import re
import select
import subprocess
import time


def run(*args):
    try:
        return subprocess.run(args, capture_output=True, text=True, timeout=3).stdout.strip()
    except Exception:
        return ""


def pactl_json(kind):
    try:
        return json.loads(run("pactl", "--format=json", "list", kind) or "[]")
    except ValueError:
        return []


def percent(dev):
    for ch in (dev.get("volume") or {}).values():
        m = re.match(r"\d+", str(ch.get("value_percent", "")))
        if m:
            return int(m.group())
    return 0


def snapshot():
    default_sink = run("pactl", "get-default-sink")
    default_source = run("pactl", "get-default-source")
    sinks = pactl_json("sinks")
    sources = pactl_json("sources")
    sink = next((s for s in sinks if s.get("name") == default_sink), None)
    src = next((s for s in sources if s.get("name") == default_source), None)
    return {
        "vol": percent(sink) if sink else 0,
        "muted": bool(sink and sink.get("mute")),
        "mic": percent(src) if src else 0,
        "mic_muted": bool(src and src.get("mute")),
        "sink": (sink or {}).get("description", "No output"),
        "sinks": [
            {
                "name": s.get("name", ""),
                "desc": s.get("description") or s.get("name", ""),
                "active": s.get("name") == default_sink,
            }
            for s in sinks
        ],
    }


last = None


def emit():
    global last
    line = json.dumps(snapshot(), separators=(",", ":"))
    if line != last:
        print(line, flush=True)
        last = line


while True:
    emit()
    try:
        proc = subprocess.Popen(
            ["pactl", "subscribe"], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, bufsize=0
        )
    except OSError:
        time.sleep(5)
        continue
    out = proc.stdout
    while True:
        line = out.readline()
        if not line:
            break
        if not re.search(rb"on (sink|source|server)", line):
            continue
        # Collapse bursts of events (e.g. while dragging a slider) into one update.
        while select.select([out], [], [], 0.08)[0]:
            if not out.readline():
                break
        emit()
    proc.wait()
    time.sleep(2)
