#!/usr/bin/env bash

source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

wifi_state=$(nmcli radio wifi | tr '[:upper:]' '[:lower:]')
active_ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)

if [[ "$wifi_state" == "enabled" ]]; then
    prompt="WiFi: On"
    mesg="Connected to: ${active_ssid:-None}"
    option_1=" Turn WiFi OFF"
else
    prompt="WiFi: Off"
    mesg="Wireless radio is disabled"
    option_1=" Turn WiFi ON"
fi

option_2=" Network Connections"
list_col='1'
list_row='2'
win_width='400px'

rofi_cmd() {
	rofi -theme-str "window {width: $win_width;}" \
		-theme-str "listview {columns: $list_col; lines: $list_row;}" \
		-theme-str 'textbox-prompt-colon {str: "直";}' \
		-theme-str 'prompt {enabled: true;}' \
		-theme-str 'window {border: 0px;}' \
		-dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		-markup-rows \
		-theme "${theme}"
}

run_rofi() {
	echo -e "$option_1\n$option_2" | rofi_cmd
}

chosen="$(run_rofi)"
case ${chosen} in
    "$option_1")
        if [[ "$wifi_state" == "enabled" ]]; then
            nmcli radio wifi off
            notify-send "WiFi" "Wireless Network Disabled"
        else
            nmcli radio wifi on
            notify-send "WiFi" "Wireless Network Enabled"
        fi
        ;;
    "$option_2")
        kitty nmtui
        ;;
esac
