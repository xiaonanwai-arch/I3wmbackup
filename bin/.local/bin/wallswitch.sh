#!/usr/bin/env bash

# Import Current Theme Configuration
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme_path="$type/$style"

# Configuration
WALLPAPER_DIR="$HOME/Livewall"
THUMB_DIR="$WALLPAPER_DIR/.thumbs"
STATE_FILE="$HOME/.current_wallpaper"
GEOMETRY="1366x768+0+0"

# Check if directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper Error" "Directory $WALLPAPER_DIR not found."
    exit 1
fi

mkdir -p "$THUMB_DIR"

# BOOT CHECK: If script is called with '--init', load the stored wallpaper immediately
if [ "$1" == "--init" ]; then
    # Read the stored filename from placeholder, default to bg.mp4 if empty/missing
    if [ -f "$STATE_FILE" ]; then
        SELECTION=$(cat "$STATE_FILE")
    else
        SELECTION="bg.mp4"
    fi
else
    # 1. Generate missing thumbnails for videos automatically
    cd "$WALLPAPER_DIR" || exit 1
    for video in *.mp4; do
        [ -e "$video" ] || continue
        thumb_name="${video%.mp4}.png"
        if [ ! -f "$THUMB_DIR/$thumb_name" ]; then
            ffmpeg -ss 00:00:01 -i "$video" -vframes 1 -q:v 2 -s 280x140 "$THUMB_DIR/$thumb_name" -y >/dev/null 2>&1
        fi
    done

    # 2. Generate list of videos formatted for Rofi gallery
    ROFI_ITEMS=""
    for video in *.mp4; do
        [ -e "$video" ] || continue
        thumb_name="${video%.mp4}.png"
        ROFI_ITEMS+="${video}\0icon\x1f${THUMB_DIR}/${thumb_name}\n"
    done

    # 3. Launch the Rofi Grid selector
    SELECTION=$(echo -en "$ROFI_ITEMS" | sort | rofi -dmenu \
        -p "   Live Wallpapers" \
        -theme "$theme_path" \
        -show-icons \
        -theme-str '
            window { width: 50%; location: center; anchor: center; border: 2.5px; border-color: @selected; border-radius: 8px; }
            inputbar { margin: 0px 0px 15px 0px; }
            listview { layout: horizontal; lines: 100; columns: 1; fixed-height: true; spacing: 32px; padding: 10px; } 
            element { orientation: vertical; padding: 1px; width: 130px; border-radius: 2px; border: 0px; opacity: 0.6; } 
            element selected { background-color: transparent; border: 1px; border-color: @selected; opacity: 1.0; }
            element-icon { size: 140px; height: 70px; horizontal-align: 0.5; vertical-align: 0.5; border-radius: 1px; }
            element-text { enabled: false; }
        ' -i)

    # Exit if no file was selected (user pressed Escape)
    if [ -z "$SELECTION" ]; then
        exit 0
    fi

    # PLACEHOLDER UPDATE: Overwrite the file with the newly selected wallpaper name
    echo "$SELECTION" > "$STATE_FILE"
fi

# Verify the file actually exists before passing it to mpv
VIDEO_PATH="$WALLPAPER_DIR/$SELECTION"
if [ ! -f "$VIDEO_PATH" ]; then
    VIDEO_PATH="$WALLPAPER_DIR/bg.mp4" # Ultimate fallback if file got deleted
fi

# Flush old layout processes
pkill -9 -f "xwinwrap"
pkill -9 -f "mpv"
sleep 0.1

# Launch the live engine wrapper


xwinwrap -g "$GEOMETRY" -b -nf -ov -fdt -- mpv --wid=%WID --loop --no-audio --no-osc --no-osd-bar --vo=x11 --stop-screensaver=no --no-input-default-bindings "$VIDEO_PATH" &


if [ "$1" != "--init" ]; then
    notify-send -u low "Live Wallpaper Changed" "Applied: $SELECTION"
fi

