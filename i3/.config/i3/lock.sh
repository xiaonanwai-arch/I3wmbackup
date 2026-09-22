#!/bin/sh

WALLPAPER=$(awk -F"'" '/feh/ { print $2; exit }' "$HOME/.fehbg" 2>/dev/null)
[ -f "$WALLPAPER" ] || WALLPAPER="$HOME/Pictures/a_cartoon_of_a_woman_in_a_pool.jpg"

LOCK_IMAGE="/tmp/i3lock-blur.png"
DIMENSIONS=$(xrandr --current | awk '/\*/ { print $1; exit }')

if [ -n "$DIMENSIONS" ] && magick "$WALLPAPER" -resize "${DIMENSIONS}^" -gravity center -extent "$DIMENSIONS" -blur 0x6 -brightness-contrast -12x0 "$LOCK_IMAGE"; then
    BACKGROUND="$LOCK_IMAGE"
else
    BACKGROUND="$WALLPAPER"
fi

TEXT='#f5f5f5ff'
MUTED='#d0d0d0cc'
CLEAR='#00000000'
WRONG='#ff6048ff'
VERIFY='#7ad9a8ff'

FONT='ComicShannsMono Nerd Font'
USER_NAME=$(id -un)

i3lock \
--image="$BACKGROUND"                 \
--clock                               \
--indicator                           \
--screen=1                            \
--noinput-text=''                     \
--verif-text='checking...'            \
--wrong-text='try again'              \
--time-str='%H:%M'                    \
--date-str='%A, %d %B'                \
--greeter-text="$USER_NAME"           \
--time-pos='w/2:h/2-60'               \
--date-pos='w/2:h/2'                  \
--greeter-pos='w/2:h/2+42'            \
--verif-pos='w/2:h/2+90'              \
--wrong-pos='w/2:h/2+90'              \
--time-align=1                        \
--date-align=1                        \
--greeter-align=1                     \
--verif-align=1                       \
--wrong-align=1                       \
--time-size=78                        \
--date-size=20                        \
--greeter-size=18                     \
--verif-size=14                       \
--wrong-size=14                       \
--time-font="$FONT"                  \
--date-font="$FONT"                  \
--greeter-font="$FONT"               \
--verif-font="$FONT"                 \
--wrong-font="$FONT"                 \
--time-color=$TEXT                    \
--date-color=$MUTED                   \
--greeter-color=$MUTED                \
--verif-color=$VERIFY                 \
--wrong-color=$WRONG                  \
--inside-color=$CLEAR                 \
--insidever-color=$CLEAR              \
--insidewrong-color=$CLEAR            \
--ring-color=$CLEAR                   \
--ringver-color=$CLEAR                \
--ringwrong-color=$CLEAR              \
--line-color=$CLEAR                   \
--separator-color=$CLEAR              \
--keyhl-color=$CLEAR                  \
--bshl-color=$CLEAR                   \
--radius=1                            \
--ring-width=0
