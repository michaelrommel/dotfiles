#!/bin/bash

PATH=/usr/bin:/usr/sbin:/bin:/sbin

NO_ONLINE=$(diskutil ar list | grep -c "^[01] .* Online ")
DISKS=$(diskutil ar list | grep "^[01] .*" | sed -e 's/^[01] *\(disk[0-9s]*\) [-0-9A-F ]* \([^ ]*\) .*/\1=\2;/g')

if [[ $NO_ONLINE != 2 ]]; then
	osascript -e "display notification \"${DISKS}\" with title \"RAID degraded\""
	{
		date -Iseconds
		echo "Online disks: ${NO_ONLINE}"
		echo "Disks: ${DISKS}" | tr "\n" " "
		echo
	} >>/Users/rommel/raid.log
fi
