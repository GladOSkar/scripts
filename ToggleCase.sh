#!/bin/bash

# Invert primary clipboard (selection)
NEWTEXT=$(xclip -o | tr 'a-zA-Z' 'A-Za-z')

# Wait until the keys arent pressed anymore to avoid retriggering
xdotool keyup "Super_L"
xdotool keyup "Caps_Lock"

# Undo Caps Locking
# Enabled  - This means the Script expects to be started by using $mod + Caps ON
# Disabled - This means the Script expects to be started by using $mod + Caps OFF
#xdotool key "Caps_Lock"

# Delete selected text
xdotool key "Delete"

# Type out
xdotool type "$NEWTEXT"

# tHIS IS A TEST string
