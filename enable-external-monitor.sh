#!/bin/bash

INTERNAL="eDP-1"
MONITOR1=`xrandr | grep " connected " | grep -v eDP | head -n 1 | cut -d ' ' -f 1`
MONITOR2=`xrandr | grep " connected " | grep -v eDP | tail -n 1 | cut -d ' ' -f 1`

if [[ $MONITOR1 ]] && [[ $MONITOR1 != $MONITOR2 ]]
then
	echo 2 Monitors
	if [[ $1 == "--vertical" ]]
	then
		 # 2 Vertical 1920x1200s
		xrandr	--output $INTERNAL --primary --auto --pos 600x1920 \
				--output $MONITOR1 --auto --pos 0x0 --rotate left \
				--output $MONITOR2 --auto --pos 1200x0 --rotate left
	else
		# T-Formation: 2 externals next to each other on top, internal in the middle below
		xrandr	--output $INTERNAL --primary --auto --pos 960x1080 \
				--output $MONITOR1 --auto --pos 0x0 \
				--output $MONITOR2 --auto --pos 1920x0
	fi
elif [[ $MONITOR1 ]]
then
	echo 1 Monitor
	# 1 external above internal
	xrandr	--output $INTERNAL --primary --auto \
			--output $MONITOR1 --auto --above $INTERNAL
fi

# Update background scaling
feh --no-fehbg --bg-scale "$HOME/Pictures/Wallpapers/42.jpg" &

# Map touchscreen to internal display
xinput --map-to-output $(xinput list --id-only "ELAN Touchscreen") $INTERNAL

if [[ $1 == "--touch" ]]
then
	xinput --map-to-output $(xinput list --id-only "ELAN Touchscreen") $MONITOR
fi
