#!/bin/bash

if [ "$(pgrep -w -x "bookworm.sh" -c)" -ne 1 ]
then
	echo "Another instance is already running"
else
	exec 1> bookworm.log 2>&1
	set -xe
	inotifywait -q \
		--monitor \
		--no-dereference \
		--recursive \
		--event create \
		--event moved_to \
		--event moved_from \
		--event delete \
		--include "^.+pdf$" \
		--format "%:e;%w%f" \
		$PWD \
	| while read line; do
	    EVENT=${line%;*}
	    FILE=${line#*;}
	    case $EVENT in
		CREATE)
		    ./add_to_library.sh "$FILE"
		    ;;
		MOVED_TO)
		    ;;
		*)
		    ;;
	    esac
	done
fi
