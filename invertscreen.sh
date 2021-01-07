#!/bin/bash

xrandr --output eDP1 --rotate $1
xinput --map-to-output $(xinput list --id-only "ELAN Touchscreen") eDP1
