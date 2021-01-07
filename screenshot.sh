#!/bin/bash

scrot -s -q 100 -o ~/Scripts/screenshot.png

paplay /usr/share/sounds/freedesktop/stereo/screen-capture.oga &

mogrify -crop +1+1 -crop -1-1 +repage ~/Scripts/screenshot.png

xclip -sel clip -t image/png -i ~/Scripts/screenshot.png
