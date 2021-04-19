#!/bin/bash

INTERNAL="eDP-1"

xinput --map-to-output $(xinput list --id-only "Wacom Bamboo One M Pen stylus") $INTERNAL
xinput --map-to-output $(xinput list --id-only "Wacom Bamboo One M Pen eraser") $INTERNAL
