#!/bin/bash

SCRIPTDIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd`

DEVICE='/sys/class/backlight/intel_backlight/brightness'

STATE=`cat $DEVICE`

if [[ $STATE == '0' ]]
then
    cat $SCRIPTDIR/last_brightness.txt > $DEVICE
else
    echo $STATE > $SCRIPTDIR/last_brightness.txt
    echo '0' > $DEVICE
fi
