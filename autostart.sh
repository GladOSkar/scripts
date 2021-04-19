#!/bin/bash

# Set external display, if any, on top of internal
$HOME/Scripts/enable-external-monitor.sh

if [[ $1 == "--login" ]]
then
	# Lock screen
	$HOME/Scripts/locker.sh
fi

xinput set-prop 'AlpsPS/2 ALPS DualPoint TouchPad' 'libinput Tapping Enabled' 1
xinput set-prop 'AlpsPS/2 ALPS DualPoint TouchPad' 'libinput Natural Scrolling Enabled' 1

xinput set-prop 'MX Master 2S Mouse' 'libinput Accel Speed' .4

# Set custom GB intl keyboard layout
setxkbmap ow oskar

# Add F12 as Menu Key
xmodmap -e "keysym F12 = Menu"

# Disable X's monitor sleep
xset s off

# Polkit
killall polkit-gnome-authentication-agent-1
/usr/lib64/polkit-gnome/polkit-gnome-authentication-agent-1 &!

# GTK theming etc
killall gsd-xsettings
/usr/lib64/gnome-settings-daemon/gsd-xsettings &!

# Due to some bug with the gtk desktop portal, unless this is done, gtk apps need 20s to start due to some timeout
dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY

# Notification daemon
# Used to start automatically but doesn't anymore?
killall dunst
dunst &!

killall solus-update-checker
solus-update-checker &!

killall clipmenud
CM_SELECTIONS=clipboard clipmenud &!

killall kdeconnectd
/usr/lib64/kf5/kdeconnectd &!

i3-msg '[instance="dropdown"] kill'
kitty --name dropdown &!

killall unclutter
unclutter -b --timeout 2 --jitter 64 &

killall ssh-agent
ssh-agent -s | tee $HOME/.ssh/ssh-agent-vars.bash
source $HOME/.ssh/ssh-agent-vars.bash
echo "set -gx SSH_AUTH_SOCK ${SSH_AUTH_SOCK}" | tee $HOME/.ssh/ssh-agent-vars.fish
echo "set -gx SSH_AGENT_PID ${SSH_AGENT_PID}" | tee -a $HOME/.ssh/ssh-agent-vars.fish

if [[ $1 == "--login" ]]
then
	# Delay until sound works?
	sleep 2
	# Ba-da-dada-da-dam! For the win XP flashbacks
	paplay "$HOME/Scripts/WinXPStartupSound.ogg" &
fi
