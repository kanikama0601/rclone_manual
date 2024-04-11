#! /bin/bash
while :; do
	rclone sync ~/js2 google_drive:js2 --update --delete-after --progress
	rclone sync google_drive:js2 ~/js2 --update --delete-after --progress
	chmod -R 777 ~/js2
	sleep 180
done
