#!/usr/bin/env bash

COLOR_CONNECTED="#50fa7b"
COLOR_DISCONNECTED="#ff5555"

STATE_FILE="/tmp/polybar_wifi_state"
SOUND_PLUG="$HOME/.config/polybar/sounds/charging.oga"
SOUND_UNPLUG="$HOME/.config/polybar/sounds/charging-cable.oga"

ssid=$(iwgetid -r 2>/dev/null)
[ -f "$STATE_FILE" ] && last_state=$(cat "$STATE_FILE") || last_state="Disconnected"

if [ -n "$ssid" ]; then
    current_state="Connected"
    output="$ssid"
else
    current_state="Disconnected"
    output="Disconnected"
fi

if [ "$current_state" = "Connected" ] && [ "$last_state" != "Connected" ]; then
    notify-send -u low -i network-wireless "Wi-Fi Connected" "Connected to $ssid"
    [ -f "$SOUND_PLUG" ] && paplay "$SOUND_PLUG" &
elif [ "$current_state" = "Disconnected" ] && [ "$last_state" = "Connected" ]; then
    notify-send -u low -i network-wireless-disconnected "Wi-Fi Disconnected" "Network connection lost"
    [ -f "$SOUND_UNPLUG" ] && paplay "$SOUND_UNPLUG" &
fi

echo "$current_state" > "$STATE_FILE"
echo "$output"

