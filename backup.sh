#!/bin/bash

DISK_UUID="a4ce0cad-36c8-4f61-b2b7-49b4ca2bbdd8"

BACKUP_NAME="oskar-torres"

BLKDEV="/dev/disk/by-uuid/$DISK_UUID"

DEST_FOLDER="/run/media/oskar/$DISK_UUID/Backups/$BACKUP_NAME"

if [ ! -d $DEST_FOLDER ]
then
    udisksctl mount -b $BLKDEV
fi

if [ ! -d $DEST_FOLDER ]
then
    echo "Something went wrong while mountig the backup drive"
    notify-send "Something went wrong while mountig the backup drive"
    exit
fi

set -B

#DIRS=($HOME/{Creds,Desktop,Documents,EBooks,Music,OSes,Pictures,Projects,Scripts,Videos,.conky,.factorio,.geanyprojects,.local/{bin,share/{applications,gnome-boxes/images}},.oh-my-zsh,.ssh,.zsh.d,.config/{i3,dunst,geany,rofi,tilda,kitty}})
#INCLUDES=`printf -- "--include='%s/***' " "${DIRS[@]}" | sed "s|${HOME}/||g"`
#EXCLUDES=`printf -- "--exclude='%s' " ".local/share/applications/chrome-*"`

FILTERFILE="$HOME/Scripts/backupfilter.txt"

echo "Starting Backup (takes a few minutes)..."
notify-send "Starting Backup (takes a few minutes)..."

STARTTIME=`date +%s`

# --dry-run -vv --out-format=%o:%f
RSYNC_CMD="rsync --archive --update --delete --delete-excluded --prune-empty-dirs --info=progress2 --filter='merge $FILTERFILE' '$HOME/' '$DEST_FOLDER/'"

echo ''
echo 'Rsync command:'
printf '%s' "$RSYNC_CMD"
echo ''

eval $RSYNC_CMD

echo ''

ENDTIME=`date +%s`

RUNTIME=$(((ENDTIME-STARTTIME)/60))

udisksctl unmount -b $BLKDEV

echo "Backup Completed in $RUNTIME Minutes!"
notify-send "Backup Completed in $RUNTIME Minutes!"
