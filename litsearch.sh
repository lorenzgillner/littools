#!/bin/bash

source ${HOME}/.config/litsearchrc

quit() {
	exit 1
}

trap quit INT

cat <<"EOF"
 _ _ _                           _     
| (_) |_ ___  ___  __ _ _ __ ___| |__  
| | | __/ __|/ _ \/ _` | '__/ __| '_ \ 
| | | |_\__ \  __/ (_| | | | (__| | | |
|_|_|\__|___/\___|\__,_|_|  \___|_| |_|

EOF

printf "This is version __VERSION__\n\n"

if [ $# -eq 1 ]; then
	IINDEX="$1"
elif [ -e "${LITSEARCH_IINDEX_PATH}" ]; then
	IINDEX="${LITSEARCH_IINDEX_PATH}"
else
	IINDEX="$(zenity --file-selection --icon-name=litsearch ${HOME})" || (echo "Canceled" && quit)
fi

echo "Index file is located at ${IINDEX}"
echo "Loading database, please wait ..."

iidxlookup.pl --title "litsearch" "${IINDEX}" | while read -r DOC; do
	echo "Opening ${DOC}"
	${LITSEARCH_READER_COMMAND} "${DOC}" 2>&1 &
done

echo "Exiting ..."

sleep 1
