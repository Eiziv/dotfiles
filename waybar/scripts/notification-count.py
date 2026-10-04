#!/usr/bin/env python3
"""Waybar module: number of notifications in dunst's history, as one JSON line per change.

Prints an empty text when there are none, so Waybar hides the badge. Event-driven (dunst
announces changes to its history length over D-Bus), with a slow poll as a safety net.
The number is capped at what the Eww notifications panel shows.
"""
import json

import gi

gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib  # noqa: E402

LIMIT = 10  # keep in sync with eww/scripts/notifications.py
BUS = "org.freedesktop.Notifications"
PATH = "/org/freedesktop/Notifications"
IFACE = "org.dunstproject.cmd0"

last = None


def emit(count):
    global last
    text = str(min(count, LIMIT)) if count > 0 else ""
    if text != last:
        last = text
        print(json.dumps({"text": text}), flush=True)


def read(connection):
    try:
        reply = connection.call_sync(
            BUS, PATH, "org.freedesktop.DBus.Properties", "Get",
            GLib.Variant("(ss)", (IFACE, "historyLength")),
            GLib.VariantType("(v)"), Gio.DBusCallFlags.NO_AUTO_START, 2000, None)
        emit(reply.unpack()[0])
    except GLib.Error:
        emit(0)  # dunst not running
    return True


def main():
    connection = Gio.bus_get_sync(Gio.BusType.SESSION, None)
    connection.signal_subscribe(
        BUS, "org.freedesktop.DBus.Properties", "PropertiesChanged", PATH, None,
        Gio.DBusSignalFlags.NONE, lambda *args: read(connection))
    read(connection)
    GLib.timeout_add_seconds(5, read, connection)
    GLib.MainLoop().run()


if __name__ == "__main__":
    main()
