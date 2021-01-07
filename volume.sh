# $1 = volume/mute , $2 = +5%/toggle
pactl set-sink-$1 @DEFAULT_SINK@ $2
paplay /usr/share/sounds/freedesktop/stereo/audio-volume-change.oga
