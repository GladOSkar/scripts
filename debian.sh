#!/bin/sh

qemu-system-x86_64 \
	-m 3G \
	-nographic \
	-serial mon:stdio \
	~/.local/share/gnome-boxes/images/boxes-unknown
