#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CONFIG_PATH="$HOME/.config/hypr/hyprpaper.conf"

while true; do
    WALL=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n 1)

    echo "preload = $WALL" > "$CONFIG_PATH"
    echo "wallpaper = ,$WALL" >> "$CONFIG_PATH"

    # Restart hyprpaper cleanly
    pkill hyprpaper
    sleep 0.5
    hyprpaper &

    sleep 300
done