#!/usr/bin/env bash

# Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

# Theme Elements
prompt="${HOSTNAME:-$(hostname)}"
mesg="Uptime : $(uptime -p | sed -e 's/up //g')"

if [[ ( "$theme" == *'type-1'* ) || ( "$theme" == *'type-3'* ) || ( "$theme" == *'type-5'* ) ]]; then
	list_col='1'
	list_row='5'
elif [[ ( "$theme" == *'type-2'* ) || ( "$theme" == *'type-4'* ) ]]; then
	list_col='5'
	list_row='1'
fi

# Options (Hardcoded to clean Icon + Text formatting)
option_1=" Lock"
option_2=" Logout"
option_3=" Suspend"
option_4=" Reboot"
option_5=" Shutdown"

# Rofi CMD
rofi_cmd() {
	rofi -theme-str "listview {columns: $list_col; lines: $list_row;}" \
		-theme-str 'textbox-prompt-colon {str: " ";}' \
		-theme-str 'prompt {enabled: true;}' \
		-theme-str 'window {border: 0px;}' \
		-dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		-markup-rows \
		-theme ${theme}
}


# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5" | rofi_cmd
}

# Execute Command
run_cmd() {
	if [[ "$1" == '--opt1' ]]; then
		~/.config/i3/lock.sh
	elif [[ "$1" == '--opt2' ]]; then
		kill -9 -1
	elif [[ "$1" == '--opt3' ]]; then
		systemctl suspend
	elif [[ "$1" == '--opt4' ]]; then
		systemctl reboot
	elif [[ "$1" == '--opt5' ]]; then
		systemctl poweroff
	fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    "$option_1")
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
    "$option_5")
		run_cmd --opt5
        ;;
esac

