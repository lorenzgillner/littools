#!/bin/bash

OPEN="zathura"

quit() {
	exit 1
}

trap quit INT

# TODO check standard path
if [ $# -eq 1 ]; then
	IIDX="$1"
else
	IIDX="$(zenity --file-selection --icon-name=litsearch)" || quit
fi

echo "Loading database ..."

iidxlookup.pl "${IIDX}" | while read -r DOC; do
	echo "${DOC}"
	nohup ${OPEN} "${DOC}" 2>/dev/null &
done

echo "Bye!"
sleep 1