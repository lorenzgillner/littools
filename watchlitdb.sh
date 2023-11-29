#!/bin/bash

inotifywait -m -q -r \
	--format '%:e "%w%f"' \
	-e create \
	-e move \
	-e delete \
	$1

# while read ...
# if create mklitentry ...
# elif delete sed path//d
# elif moved_from ...
#   old name ...
#   if next event moved_to ...
#     new name ...
#       sed s/old name/new name/s/old tags/new tags/g