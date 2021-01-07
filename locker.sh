#!/bin/bash

# scrot lockshot.png -q 100
# mogrify -blur 0x4 lockshot.png
# mogrify -resize 12.5% -resize 800% lockshot.png
# mogrify -filter Gaussian -resize 25% -define filter:sigma=.8 -resize 400% lockshot.png
# $ xrandr | grep -sw 'connected' | wc -l # Number of monitors

paplay /usr/share/sounds/freedesktop/stereo/service-logout.oga &

RES=$(xdpyinfo  | grep -oP --color=never 'dimensions:\s+\K\S+') # Current Resolution

ffmpeg -f x11grab -s $RES -y -i $DISPLAY -vf "boxblur=4:4" -vframes 1 ~/Scripts/lockshot.png

i3lock -i ~/Scripts/lockshot.png -c 000000
