#!/bin/bash

ESSID=`nmcli dev wifi | rofi -dmenu -i -p Network | awk '{print $1 == "*" ? $2 : $1}'`

if [[ $ESSID = "IN-USE" ]]
then
    notify-send "You can't choose that, dummy"
    exit 1
fi

echo "ESSID = '$ESSID'"

PSK=`rofi -dmenu -p "Password for '$ESSID'"`

echo "PSK = '$PSK'"

STATUS=`nmcli dev wifi connect $ESSID password $PSK`

echo "STATUS = '$STATUS'"

if [[ $STATUS = *"successfull"* ]]
then
    notify-send "Successfully connected to '$ESSID'"
else
    notify-send "$STATUS"
fi
