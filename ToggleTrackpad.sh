#!/bin/bash

DEVICE="AlpsPS/2 ALPS DualPoint TouchPad"

ENABLED=`xinput list-props "$DEVICE" | grep "Device Enabled" | grep -o "[01]$"`

if [ $ENABLED == '1' ]
then
  xinput --disable "$DEVICE"
  notify-send "Trackpad" "OFF" -i input-touchpad
else
  xinput --enable "$DEVICE"
  notify-send "Trackpad" "ON" -i input-touchpad
fi
