#!/usr/bin/env bash

# Import Current Theme Configuration
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme_path="$type/$style"

# Configuration
WALLPAPER_DIR="/home/kai/Pictures"
EXTENSIONS="jpg|jpeg|png|webp|bmp"
SDDM_BACKGROUND="/usr/share/sddm/themes/Abhi/bg.png"

# Check if directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper Error" "Directory $WALLPAPER_DIR not found."
    exit 1
fi

# Generate list of images formatted with Rofi icon delimiters
ROFI_ITEMS=""
while IFS= read -r file; do
    if [ -n "$file" ]; then
        ROFI_ITEMS+="${file}\0icon\x1f${WALLPAPER_DIR}/${file}\n"
    fi
done < <(ls -1 "$WALLPAPER_DIR" | grep -E -i "\.(${EXTENSIONS})$")

# Verify that images were found
if [ -z "$ROFI_ITEMS" ]; then
    notify-send "Wallpaper Error" "No valid image files found in $WALLPAPER_DIR"
    exit 1
fi

update_sddm_background() {
    local wallpaper=$1
    local tmp_file
    local dimensions

    command -v magick >/dev/null 2>&1 || return

    tmp_file=$(mktemp --suffix=.png) || return
    dimensions=$(xrandr --current 2>/dev/null | awk '/\*/ { print $1; exit }')

    if [ -n "$dimensions" ] && magick "$wallpaper" -resize "${dimensions}^" -gravity center -extent "$dimensions" -brightness-contrast -12x0 "$tmp_file"; then
        if [ -w "$SDDM_BACKGROUND" ]; then
            install -m 644 "$tmp_file" "$SDDM_BACKGROUND"
        elif command -v pkexec >/dev/null 2>&1; then
            pkexec install -m 644 "$tmp_file" "$SDDM_BACKGROUND"
        elif command -v sudo >/dev/null 2>&1; then
            sudo install -m 644 "$tmp_file" "$SDDM_BACKGROUND"
        fi
    fi

    rm -f "$tmp_file"
}

# Launch Rofi with a fullscreen wallpaper gallery layout
SELECTION=$(echo -en "$ROFI_ITEMS" | rofi -dmenu \
    -p "" \
    -theme "$theme_path" \
    -show-icons \
    -theme-str '
        window {
            width: 102%;
            location: center;
            anchor: center;
            background-color: transparent;
            border: 0px;
            border-color: @selected;
            border-radius: 20px;
            padding: 15px;
        }
        mainbox {
            background-color: transparent;
            children: [listview];
            padding: 0px;
        }
        inputbar {
            enabled: false;
        }
        listview {
            background-color: transparent;
            columns: 6;
            lines: 1;
            spacing: 20px;
            padding: 8px 12px;
            cycle: true;
            dynamic: false;
            scrollbar: false;
            layout: vertical;
            reverse: true;
            fixed-height: true;
            fixed-columns: true;
            cursor: "default";
        }
        element {
            orientation: vertical;
            padding: 0px;
            border-radius: 16px;
            background-color: transparent;
            spacing: 0px;
        }
        element selected {
            background-color: @selected;
        }
        element-icon {
            size: 28%;
            cursor: inherit;
            border-radius: 0px;
            background-color: transparent;
            horizontal-align: 0.5;
            vertical-align: 0.5;
        }
        element-text {
            enabled: true;
            vertical-align: 0.5;
            horizontal-align: 0.5;
            padding: 10px;
            cursor: inherit;
            background-color: transparent;
            text-color: inherit;
            font: "ComicShannsMono Nerd Font 10";
        }
    ' \
    -i)

# If an image is selected, apply it using feh
if [ -n "$SELECTION" ]; then
    WALLPAPER="$WALLPAPER_DIR/$SELECTION"
    feh --bg-fill "$WALLPAPER"
    update_sddm_background "$WALLPAPER"
    notify-send -u low "Wallpaper Changed" "Applied: $SELECTION"
fi

