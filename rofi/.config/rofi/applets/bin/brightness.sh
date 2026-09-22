#!/usr/bin/env bash

# Hardcoded absolute path
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"


# Brightness Info (Fallback value included if utility reads an empty string)
raw_light="`light -G 2>/dev/null`"
backlight="$(printf "%.0f\n" "${raw_light:-50}")"
card="`light -L 2>/dev/null | grep 'backlight' | head -n1 | cut -d'/' -f3`"

if [[ -z "$card" ]]; then
	card="Display"
fi

if [[ $backlight -ge 0 ]] && [[ $backlight -le 29 ]]; then
    level="Low"
elif [[ $backlight -ge 30 ]] && [[ $backlight -le 49 ]]; then
    level="Optimal"
elif [[ $backlight -ge 50 ]] && [[ $backlight -le 69 ]]; then
    level="High"
elif [[ $backlight -ge 70 ]] && [[ $backlight -le 100 ]]; then
    level="Peak"
fi

prompt="${backlight}%"
mesg="Device: ${card}, Level: $level"
list_col='1'
list_row='4'
win_width='400px'

# Set layout string manually to prevent cat parsing error
layout="NO"

if [[ "$layout" == 'NO' ]]; then
	option_1=" Increase"
	option_2=" Optimal"
	option_3=" Decrease"
	option_4=" Settings"
else
	option_1=""
	option_2=""
	option_3=""
	option_4=""
fi

rofi_cmd() {
	rofi -theme-str "window {width: $win_width;}" \
		-theme-str "listview {columns: $list_col; lines: $list_row;}" \
		-theme-str 'textbox-prompt-colon {str: "";}' \
		-dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		-markup-rows \
		-theme "${theme}"
}

run_rofi() {
	echo -e "$option_1\n$option_2\n$option_3\n$option_4" | rofi_cmd
}

run_cmd() {
	if [[ "$1" == '--opt1' ]]; then
		light -A 5
	elif [[ "$1" == '--opt2' ]]; then
		light -S 25
	elif [[ "$1" == '--opt3' ]]; then
		light -U 5
	elif [[ "$1" == '--opt4' ]]; then
		xfce4-power-manager-settings
	fi
}

chosen="$(run_rofi)"
case ${chosen} in
    "$option_1") # Quotes added for Zsh compatibility
		run_cmd --opt1
        ;;
    "$option_2")
		run_cmd --opt2
        ;;
    "$option_3")
		run_cmd --opt3
        ;;
    "$option_4")
		run_cmd --opt4
        ;;
esac

