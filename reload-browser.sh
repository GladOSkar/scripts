#!/bin/sh
# reload-browser - A cross-platform wrapper for reloading the current
# browser tab
# Eric Radman, 2014
# http://eradman.com/entrproject/scripts/

echo Trigger

if [ $# -lt 1 ]
then
	echo "Usage: $0 <TitlePattern>"
	exit 1
fi

for NAME in "$@"
do

	CW=`xdotool getwindowfocus -f`

	xdotool search --onlyvisible --name "$NAME" windowfocus key --delay 100 F5

	sleep 0.2

	xdotool windowfocus $CW

	echo Reloaded $NAME

done
