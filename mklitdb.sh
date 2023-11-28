#!/usr/bin/env sh

FINDCMD=fdfind

if [ $# -ne 1 ]; then
	echo "Usage: mklitdb.sh <directory>"
	exit 1
fi

ROOTDIR="$1"

$FINDCMD ".+\.pdf" "$ROOTDIR" | parallel mklitentry.sh {}
