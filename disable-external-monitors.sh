#!/bin/bash

for OFF in `xrandr | grep "connected " | grep -v eDP | cut -d ' ' -f 1`
do
	xrandr --output $OFF --off
done

xinput --map-to-output $(xinput list --id-only "ELAN Touchscreen") eDP-1
