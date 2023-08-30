#!/bin/bash

VERSION=0.1
OPEN="zathura"

quit() {
	exit 1
}

trap quit INT

cat <<"EOT"
 _ _ _                           _     
| (_) |_ ___  ___  __ _ _ __ ___| |__  
| | | __/ __|/ _ \/ _` | '__/ __| '_ \ 
| | | |_\__ \  __/ (_| | | | (__| | | |
|_|_|\__|___/\___|\__,_|_|  \___|_| |_|

EOT

echo "version ${VERSION}"

if [ $# -eq 1 ]; then
	IIDX="$1"
elif [ -e ${HOME}/.iidx.csv ]; then
	IIDX="${HOME}/.iidx.csv"
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
