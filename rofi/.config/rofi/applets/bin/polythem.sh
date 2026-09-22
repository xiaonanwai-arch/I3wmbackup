#!/usr/bin/env bash

source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

# Paths Configuration
POLYBAR_DIR="$HOME/.config/polybar"
THEMES_DIR="$POLYBAR_DIR/themes"
MASTER_COLORS="$POLYBAR_DIR/colors.ini"

# Ensure the themes directory exists
if [ ! -d "$THEMES_DIR" ]; then
    echo "Themes directory not found at $THEMES_DIR"
    exit 1
fi

# Get list of available theme names (removes directory path and .ini extension)
themes=$(find "$THEMES_DIR" -maxdepth 1 -type f -name "*.ini" -exec basename {} .ini \;)

if [ -z "$themes" ]; then
    echo "No .ini theme files found in $THEMES_DIR"
    exit 1
fi

# Present the themes via Rofi
chosen_theme=$(echo "$themes" | rofi -dmenu -i -p "Select Polybar Theme:")

# Exit if no theme was chosen (e.g., user pressed Escape)
if [ -z "$chosen_theme" ]; then
    exit 0
fi

# Construct the exact include line to write
new_include_line="include-file = $THEMES_DIR/$chosen_theme.ini"

# Overwrite colors.ini with the new path
echo "$new_include_line" > "$MASTER_COLORS"

# Reload Polybar to apply changes instantly
if pgrep -x polybar > /dev/null; then
    polybar-msg cmd restart
else
    # Fallback script launch if polybar wasn't running
    "$POLYBAR_DIR/launch.sh" &
fi

notify-send "Polybar Theme" "Switched to $chosen_theme theme smoothly!"

