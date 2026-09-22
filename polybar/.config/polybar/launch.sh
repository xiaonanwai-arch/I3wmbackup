#!/usr/bin/env bash

# # Terminate already running bar instances
# killall -q polybar
#
# # Wait until the processes have been shut down
# while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
#
# # Launch your bar (replace "main" with your actual bar name from config.ini)
# polybar main &
#
#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Dynamically detect active X11 outputs and run a bar on each
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload main &
  done
else
  polybar --reload main &
fi



