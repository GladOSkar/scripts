#!/bin/bash

if [ "$1" == "-h" ]
then
    pulseaudio -k
fi

NEWSINKID=`pactl list short sinks | rofi -dmenu -p "Output device" | cut -d ' ' -f 1 | cut -d $'\t' -f 1`

echo "Chose sink #$NEWSINKID"

pactl set-default-sink "$NEWSINKID"

pactl list short sink-inputs | while read STREAM
do
    STREAMID=`echo $STREAM | cut -d ' ' -f 1 | cut -d $'\t' -f 1`
    echo "Moving stream $STREAMID"
    pactl move-sink-input "$STREAMID" "$NEWSINKID"
done

exit 0
