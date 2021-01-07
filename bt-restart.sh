#!/bin/bash

rfkill block bluetooth

rfkill unblock bluetooth

notify-send 'Bluetooth restarted'
