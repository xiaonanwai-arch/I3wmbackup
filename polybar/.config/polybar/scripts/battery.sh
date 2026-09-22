#!/usr/bin/env bash

COLOR_CHARGING="#7ad9a8"
COLOR_BATTERY="#5fc8d4"
COLOR_LOW="#ff6048"

LOW_THRESHOLD=25

STATE_FILE="/tmp/polybar_bat_state"
LOCK_LOW="/tmp/polybar_bat_low"

SOUND_PLUG="$HOME/.config/polybar/sounds/charging.oga"
SOUND_UNPLUG="$HOME/.config/polybar/sounds/charging-cable.oga"
SOUND_LOW="$HOME/.config/polybar/sounds/low-battery.oga"

# Check if AC adapter is plugged in
ac_adapter=$(acpi -a 2>/dev/null)
is_plugged=false
if [[ "$ac_adapter" == *"on-line"* ]]; then
    is_plugged=true
fi

info=$(acpi -b 2>/dev/null | head -n 1)
if [ -z "$info" ]; then
    echo "   N/A"
    exit 1
fi

if [[ $info =~ ([0-9]+)% ]]; then
    percent="${BASH_REMATCH[1]}"
else
    echo "   N/A"
    exit 1
fi

# Override "Not charging" if we are safely plugged into the wall
case "$info" in
    *"Charging"*) status="Charging" ;;
    *"Full"*) status="Full" ;;
    *"Not charging"*) 
        if [ "$is_plugged" = true ]; then
            status="Charging" # Treat conservation mode as charging
        else
            status="Discharging"
        fi
        ;;
    *) status="Discharging" ;;
esac

if [ -f "$STATE_FILE" ]; then
    last_state=$(<"$STATE_FILE")
else
    last_state="Unknown"
fi

play_sound() {
    local sound_file=$1
    if [ -f "$sound_file" ] && command -v paplay >/dev/null 2>&1; then
        paplay "$sound_file" &
    fi
}

send_notification() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "$@"
    fi
}

# Action: Plugged In
if [ "$status" = "Charging" ] && [ "$last_state" != "Charging" ]; then
    send_notification -u low -i battery-charging "Charger Connected" "Your system is now charging ($percent%)."
    play_sound "$SOUND_PLUG"
    rm -f "$LOCK_LOW"

# Action: Unplugged
elif [ "$status" != "Charging" ] && [ "$last_state" = "Charging" ]; then
    send_notification -u low -i battery "Charger Disconnected" "Running on battery power ($percent%)."
    play_sound "$SOUND_UNPLUG"
    if [ "$percent" -le "$LOW_THRESHOLD" ]; then
        touch "$LOCK_LOW"
    fi
fi

# Low Battery Check
if [ "$status" != "Charging" ] && [ "$last_state" != "Charging" ] && [ "$percent" -le "$LOW_THRESHOLD" ]; then
    if [ ! -f "$LOCK_LOW" ]; then
        touch "$LOCK_LOW"
        send_notification -u critical -i battery-low "Battery Low" "Battery is at ${percent}%. Please plug in your charger."
        play_sound "$SOUND_LOW"
    fi
fi

if [ "$percent" -gt "$LOW_THRESHOLD" ]; then
    rm -f "$LOCK_LOW"
fi

echo "$status" > "$STATE_FILE"

# Colors
if [ "$status" = "Full" ] || [ "$percent" -eq 100 ]; then
    color="$COLOR_BATTERY"
elif [ "$status" = "Charging" ]; then
    color="$COLOR_CHARGING"
elif [ "$percent" -le "$LOW_THRESHOLD" ]; then
    color="$COLOR_LOW"
else
    color="$COLOR_BATTERY"
fi

# Icons
if [ "$status" = "Full" ] || [ "$percent" -ge 80 ]; then
    icon=""
elif [ "$percent" -ge 60 ]; then
    icon=""
elif [ "$percent" -ge 40 ]; then
    icon=""
elif [ "$percent" -ge 20 ]; then
    icon=""
else
    icon=""
fi

echo "%{F${color}}${icon}%{F-} $percent%"

