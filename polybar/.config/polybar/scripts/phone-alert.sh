#!/usr/bin/env bash

last_state="disconnected"

while true; do
    if lsusb | grep -qiE 'phone|android|apple|samsung|pixel|mtp'; then
        current_state="connected"
    else
        current_state="disconnected"
    fi

    if [ "$current_state" = "connected" ] && [ "$last_state" = "disconnected" ]; then
        notify-send -u low -i phone "Phone Connected" "Mobile device detected via USB."
    elif [ "$current_state" = "disconnected" ] && [ "$last_state" = "connected" ]; then
        notify-send -u low -i phone "Phone Disconnected" "Mobile device removed."
    fi

    last_state="$current_state"
    sleep 2
done


