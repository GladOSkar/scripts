#!/bin/bash

HEADSETADDR="F4:0E:11:72:05:BA"

echo -en "Activating bluetooth & connecting...\t"

bluetoothctl > /dev/null <<-EOM
	power on
	agent on
	pair $HEADSETADDR
	connect $HEADSETADDR
	exit
EOM

echo "Activated & connected to $HEADSETADDR."

echo -en "Waiting for audio connection...\t\t"

BLUEZSINK=`pactl list short sinks | grep bluez`
while [[ $? != 0 ]]
do
	sleep 1
	BLUEZSINK=`pactl list short sinks | grep bluez`
done

echo "Audio connected."

#echo "Sink: $BLUEZSINK"

echo -n "Switching audio device "

SINKID=`echo $BLUEZSINK | cut -d ' ' -f 1 | cut -d $'\t' -f 1`

echo -en "to sink #$SINKID...\t"

pactl set-default-sink "$SINKID"

pactl list short sink-inputs | while read STREAM
do
    STREAMID=`echo $STREAM | cut -d ' ' -f 1 | cut -d $'\t' -f 1`
    echo "Moving stream $STREAMID"
    pactl move-sink-input "$STREAMID" "$SINKID"
done

echo "Switched audio device"
