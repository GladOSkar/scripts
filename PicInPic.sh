#!/bin/bash

xdotool key --clearmodifiers f	# Youtube Fullscreen
i3-msg fullscreen disable		# Exit i3 Fullscreen, keep Youtube Fullscreen
i3-msg floating enable			# Float Window
i3-msg resize set 640 360		# Resize Window
i3-msg sticky enable			# Sticky (on all Workspaces)
i3-msg move position 1240 640	# Bottom right
